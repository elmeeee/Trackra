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
    private let authManager: AuthenticationManager
    
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
    
    func createApplication(role: String, company: String, appliedAt: Date, source: String, salaryRange: String, location: String, url: String) async {
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
        } catch let apiError as APIError {
            error = apiError
        } catch let networkError {
            error = .networkError(networkError)
        }
        
        isLoading = false
    }
    
    func createActivity(applicationId: String, type: ActivityType, occurredAt: Date, note: String) async {
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
