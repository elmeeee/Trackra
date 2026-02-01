//
//  AppState.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var applications: [Application] = []
    @Published var selectedApplicationId: String?
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var showingAddApplication = false
    @Published var showingAddActivity = false
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
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
        isLoading = true
        error = nil
        
        do {
            applications = try await apiClient.fetchApplications()
        } catch let apiError as APIError {
            error = apiError
        } catch let networkError {
            error = .networkError(networkError)
        }
        
        isLoading = false
    }
    
    func createApplication(role: String, company: String, appliedAt: Date, source: String, salaryRange: String, location: String, url: String) async {
        isLoading = true
        error = nil
        
        do {
            _ = try await apiClient.createApplication(
                role: role,
                company: company,
                appliedAt: appliedAt,
                source: source,
                salaryRange: salaryRange,
                location: location,
                url: url
            )
            await loadApplications()
        } catch let apiError as APIError {
            error = apiError
        } catch let networkError {
            error = .networkError(networkError)
        }
        
        isLoading = false
    }
    
    func createActivity(applicationId: String, type: ActivityType, occurredAt: Date, note: String) async {
        isLoading = true
        error = nil
        
        do {
            _ = try await apiClient.createActivity(
                applicationId: applicationId,
                type: type,
                occurredAt: occurredAt,
                note: note
            )
            await loadApplications()
        } catch let apiError as APIError {
            error = apiError
        } catch let networkError {
            error = .networkError(networkError)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadApplications()
    }
}
