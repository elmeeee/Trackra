//
//  AuthenticationManager.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum AuthState {
    case splash
    case login
    case authenticated
}

@MainActor
final class AuthenticationManager: ObservableObject {
    @Published var authState: AuthState = .splash
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userEmail: String?
    
    private let apiClient: APIClientProtocol
    private let keychain = KeychainService.shared
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
        checkExistingAuth()
    }
    
    func checkExistingAuth() {
        if let apiKey = keychain.getApiKey(), !apiKey.isEmpty {
            userEmail = keychain.getEmail()
            authState = .authenticated
        }
    }
    
    func performHealthCheck() async {
        do {
            let isHealthy = try await apiClient.checkHealth()
            if isHealthy {
                // Wait minimum 1.5 seconds for splash screen
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                // Check if user is already authenticated
                if keychain.getApiKey() != nil {
                    authState = .authenticated
                } else {
                    authState = .login
                }
            } else {
                authState = .login
            }
        } catch {
            // Even if health check fails, proceed to login
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            authState = .login
        }
    }
    
    func login(email: String, password: String, rememberMe: Bool = true) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let apiKey = try await apiClient.login(email: email, password: password)
            
            // Save credentials
            _ = keychain.saveApiKey(apiKey)
            if rememberMe {
                _ = keychain.saveEmail(email)
            } else {
                _ = keychain.deleteEmail()
            }
            
            userEmail = email
            isLoading = false
            authState = .authenticated
        } catch let error as APIError {
            isLoading = false
            errorMessage = error.errorDescription ?? "Login failed"
        } catch {
            isLoading = false
            errorMessage = "An unexpected error occurred"
        }
    }
    
    func logout() {
        _ = keychain.clearAll()
        userEmail = nil
        authState = .login
    }
    
    func getApiKey() -> String? {
        return keychain.getApiKey()
    }
    
    func getSavedEmail() -> String? {
        return keychain.getEmail()
    }
}
