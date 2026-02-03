//
//  AppState.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import UserNotifications

@MainActor
final class AppState: ObservableObject {
    @Published var applications: [Application] = []
    @Published var selectedApplicationId: String?
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var showingAddApplication = false
    @Published var showingAddActivity = false
    @Published var processingApplicationId: String?
    @Published var successMessage: String?
    @Published var activityTypeToAdd: ActivityType?

    private let apiClient: APIClientProtocol
    let authManager: AuthenticationManager
    let notificationManager = NotificationManager.shared

    init(apiClient: APIClientProtocol = APIClient(), authManager: AuthenticationManager) {
        self.apiClient = apiClient
        self.authManager = authManager
    }

    var selectedApplication: Application? {
        guard let selectedApplicationId else { return nil }
        return applications.first { $0.id == selectedApplicationId }
    }

    var sortedApplications: [Application] {
        applications.sorted { app1, app2 in
            let date1 = app1.activities.map(\.occurredAt).max() ?? app1.appliedAt
            let date2 = app2.activities.map(\.occurredAt).max() ?? app2.appliedAt
            return date1 > date2
        }
    }

    func loadApplications(withLoadingState: Bool = true) async {
        guard let apiKey = authManager.getApiKey(), !apiKey.isEmpty else {
            // Don't show error if not authenticated, just return
            isLoading = false
            return
        }

        if withLoadingState {
            isLoading = true
        }
        error = nil

        do {
            applications = try await apiClient.fetchApplications(apiKey: apiKey)
        } catch let apiError as APIError {
            error = apiError
        } catch let networkError {
            error = .networkError(networkError)
        }

        if withLoadingState {
            isLoading = false
        }
    }

    func createApplication(
        role: String, company: String, appliedAt: Date, source: String, salaryRange: String,
        location: String, url: String
    ) async {
        guard let apiKey = authManager.getApiKey(), !apiKey.isEmpty else {
            error = .serverError("Not authenticated")
            return
        }

        isLoading = true
        error = nil

        do {
            _ = try await apiClient.createApplication(
                apiKey: apiKey,
                role: role,
                company: company,
                appliedAt: appliedAt,
                source: source,
                salaryRange: salaryRange,
                location: location,
                url: url
            )
            HapticManager.shared.notification(type: .success)
            await loadApplications(withLoadingState: false)
            successMessage = "Application added successfully!"
        } catch let apiError as APIError {
            HapticManager.shared.notification(type: .error)
            error = apiError
        } catch let networkError {
            HapticManager.shared.notification(type: .error)
            error = .networkError(networkError)
        }

        isLoading = false
    }

    func createActivity(applicationId: String, type: ActivityType, occurredAt: Date, note: String)
        async
    {
        guard let apiKey = authManager.getApiKey(), !apiKey.isEmpty else {
            error = .serverError("Not authenticated")
            return
        }

        guard let index = applications.firstIndex(where: { $0.id == applicationId }) else { return }

        // Optimistic Update
        let originalApp = applications[index]
        var optimisticApp = originalApp
        let tempActivity = Activity(
            id: UUID().uuidString,
            applicationId: applicationId,
            type: type,
            occurredAt: occurredAt,
            note: note
        )
        optimisticApp.activities.insert(tempActivity, at: 0)  // Newest first
        applications[index] = optimisticApp

        processingApplicationId = applicationId
        error = nil

        HapticManager.shared.impact(style: .medium)

        do {
            _ = try await apiClient.createActivity(
                apiKey: apiKey,
                applicationId: applicationId,
                type: type,
                occurredAt: occurredAt,
                note: note
            )

            // Check if we should update the application status based on this new activity
            if let newStatus = type.associatedStatus, newStatus != originalApp.status {
                // Check if this activity is the latest/highest precedence
                let isLatest: Bool
                if originalApp.activities.isEmpty {
                    isLatest = true
                } else {
                    let currentBest = originalApp.activities.max { a, b in
                        if a.occurredAt != b.occurredAt { return a.occurredAt < b.occurredAt }
                        return a.type.sortOrder < b.type.sortOrder
                    }

                    if let currentBest {
                        if occurredAt > currentBest.occurredAt {
                            isLatest = true
                        } else if occurredAt == currentBest.occurredAt
                            && type.sortOrder >= currentBest.type.sortOrder
                        {
                            isLatest = true
                        } else {
                            isLatest = false
                        }
                    } else {
                        isLatest = true
                    }
                }

                if isLatest {
                    try await apiClient.updateStatus(
                        apiKey: apiKey, applicationId: applicationId, status: newStatus)
                }
            }

            HapticManager.shared.notification(type: .success)
            await loadApplications(withLoadingState: false)
            successMessage = getSuccessMessage(for: type)

            // Smart Reminder
            if let index = applications.firstIndex(where: { $0.id == applicationId }) {
                let app = applications[index]
                let activity = Activity(
                    id: UUID().uuidString,  // ID doesn't match API but fine for local notification
                    applicationId: applicationId,
                    type: type,
                    occurredAt: occurredAt,
                    note: note
                )
                scheduleReminder(for: activity, application: app)
            }
        } catch let apiError as APIError {
            // Revert
            applications[index] = originalApp
            HapticManager.shared.notification(type: .error)
            error = apiError
        } catch let networkError {
            // Revert
            applications[index] = originalApp
            HapticManager.shared.notification(type: .error)
            error = .networkError(networkError)
        }

        processingApplicationId = nil
    }

    func updateStatus(applicationId: String, newStatus: ApplicationStatus) async {
        guard let apiKey = authManager.getApiKey(), !apiKey.isEmpty else {
            error = .serverError("Not authenticated")
            return
        }

        guard let index = applications.firstIndex(where: { $0.id == applicationId }) else {
            return
        }

        let oldApplication = applications[index]

        var updatedApplication = oldApplication
        updatedApplication.status = newStatus
        applications[index] = updatedApplication

        HapticManager.shared.impact(style: .medium)

        do {
            try await apiClient.updateStatus(
                apiKey: apiKey, applicationId: applicationId, status: newStatus)
            HapticManager.shared.notification(type: .success)
            await loadApplications(withLoadingState: false)
            successMessage = "Status updated to \(newStatus.displayName)"
        } catch let apiError as APIError {
            HapticManager.shared.notification(type: .error)
            applications[index] = oldApplication
            error = apiError
        } catch let networkError {
            HapticManager.shared.notification(type: .error)
            applications[index] = oldApplication
            error = .networkError(networkError)
        }
    }

    func deleteApplication(applicationId: String) async {
        guard let apiKey = authManager.getApiKey(), !apiKey.isEmpty else {
            error = .serverError("Not authenticated")
            return
        }

        guard let index = applications.firstIndex(where: { $0.id == applicationId }) else {
            return
        }

        let deletedApplication = applications[index]
        applications.remove(at: index)

        if selectedApplicationId == applicationId {
            selectedApplicationId = nil
        }

        HapticManager.shared.impact(style: .heavy)

        do {
            try await apiClient.deleteApplication(apiKey: apiKey, applicationId: applicationId)
            HapticManager.shared.notification(type: .success)
            successMessage = "Application deleted successfully"
        } catch let apiError as APIError {
            HapticManager.shared.notification(type: .error)
            applications.insert(deletedApplication, at: index)
            error = apiError
        } catch let networkError {
            HapticManager.shared.notification(type: .error)
            applications.insert(deletedApplication, at: index)
            error = .networkError(networkError)
        }
    }

    func refresh() async {
        HapticManager.shared.impact(style: .light)
        error = nil  // Clear any existing errors
        await loadApplications()
        HapticManager.shared.notification(type: .success)
    }

    private func getSuccessMessage(for activityType: ActivityType) -> String {
        switch activityType {
        case .hrScreen:
            return "HR screen recorded successfully!"
        case .recruiterCall:
            return "Recruiter call recorded successfully!"
        case .hiringManagerInterview:
            return "Hiring manager interview recorded!"
        case .panelInterview:
            return "Panel interview recorded!"
        case .onsiteInterview:
            return "Onsite interview recorded!"
        case .technicalTest:
            return "Technical test recorded!"
        case .takeHomeTest:
            return "Take-home test recorded!"
        case .interviewScheduled:
            return "Interview scheduled successfully!"
        case .interviewDone:
            return "Interview marked as done!"
        case .followUp:
            return "Follow-up added successfully!"
        case .offerReceived:
            return "Offer received! Congratulations!"
        case .rejected:
            return "Application marked as rejected"
        case .note:
            return "Note added successfully!"
        }
    }

    private func scheduleReminder(for activity: Activity, application: Application) {
        // Only schedule if in future
        guard activity.occurredAt > Date() else { return }

        // Only for interview-like activities
        let interviewTypes: [ActivityType] = [
            .hrScreen, .recruiterCall, .hiringManagerInterview, .panelInterview, .onsiteInterview,
            .technicalTest, .interviewScheduled,
        ]

        guard interviewTypes.contains(activity.type) else { return }

        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Interview Reminder: \(application.company)"
        content.body = "Upcoming \(activity.type) for \(application.role)."
        content.sound = .default

        // Reminder 1 hour before
        let triggerDate = activity.occurredAt.addingTimeInterval(-3600)

        if triggerDate < Date() { return }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "activity-\(activity.id)", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
