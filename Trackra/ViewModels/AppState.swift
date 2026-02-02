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

@MainActor
final class AppState: ObservableObject {
    @Published var applications: [Application] = []
    @Published var selectedApplicationId: String?
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var showingAddApplication = false
    @Published var showingAddActivity = false
    @Published var successMessage: String?

    private let apiClient: APIClientProtocol
    let authManager: AuthenticationManager

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

    func loadApplications() async {
        guard let apiKey = authManager.getApiKey(), !apiKey.isEmpty else {
            // Don't show error if not authenticated, just return
            isLoading = false
            return
        }

        isLoading = true
        error = nil

        do {
            applications = try await apiClient.fetchApplications(apiKey: apiKey)
        } catch let apiError as APIError {
            error = apiError
        } catch let networkError {
            error = .networkError(networkError)
        }

        isLoading = false
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
            await loadApplications()
            successMessage = "Application added successfully!"
        } catch let apiError as APIError {
            error = apiError
        } catch let networkError {
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

        isLoading = true
        error = nil

        do {
            _ = try await apiClient.createActivity(
                apiKey: apiKey,
                applicationId: applicationId,
                type: type,
                occurredAt: occurredAt,
                note: note
            )
            await loadApplications()
            successMessage = getSuccessMessage(for: type)
        } catch let apiError as APIError {
            error = apiError
        } catch let networkError {
            error = .networkError(networkError)
        }

        isLoading = false
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

        do {
            try await apiClient.updateStatus(
                apiKey: apiKey, applicationId: applicationId, status: newStatus)
            await loadApplications()
            successMessage = "Status updated to \(newStatus.displayName)"
        } catch let apiError as APIError {
            applications[index] = oldApplication
            error = apiError
        } catch let networkError {
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

        do {
            try await apiClient.deleteApplication(apiKey: apiKey, applicationId: applicationId)
            successMessage = "Application deleted successfully"
        } catch let apiError as APIError {
            applications.insert(deletedApplication, at: index)
            error = apiError
        } catch let networkError {
            applications.insert(deletedApplication, at: index)
            error = .networkError(networkError)
        }
    }

    func refresh() async {
        error = nil  // Clear any existing errors
        await loadApplications()
    }

    private func getSuccessMessage(for activityType: ActivityType) -> String {
        switch activityType {
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
}
