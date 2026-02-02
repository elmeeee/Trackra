//
//  APIClient.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation

protocol APIClientProtocol {
    func checkHealth() async throws -> Bool
    func login(email: String, password: String) async throws -> String
    func fetchApplications(apiKey: String) async throws -> [Application]
    func createApplication(apiKey: String, role: String, company: String, appliedAt: Date, source: String, salaryRange: String, location: String, url: String) async throws -> String
    func createActivity(apiKey: String, applicationId: String, type: ActivityType, occurredAt: Date, note: String) async throws -> String
    func fetchNotifications(apiKey: String) async throws -> [AppNotification]
}

final class APIClient: APIClientProtocol {
    private let baseURL = "https://script.google.com/macros/s/AKfycbwMp-NQ3-SlnrdIQMboGLKjxX_YmLdOTL9dC2fUy65ekFBtnfwpslP1IIYE5u8VBUrB/exec"
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    nonisolated init(session: URLSession? = nil) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        self.session = session ?? URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            
            let fallbackFormatter = ISO8601DateFormatter()
            fallbackFormatter.formatOptions = [.withInternetDateTime]
            if let date = fallbackFormatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    func checkHealth() async throws -> Bool {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        urlComponents.queryItems = [URLQueryItem(name: "path", value: "health")]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        let request = URLRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let healthResponse = try decoder.decode(HealthResponse.self, from: data)
            return healthResponse.ok
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func login(email: String, password: String) async throws -> String {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        urlComponents.queryItems = [URLQueryItem(name: "path", value: "auth/login")]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(email: email, password: password)
        request.httpBody = try encoder.encode(loginRequest)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let loginResponse = try decoder.decode(LoginResponse.self, from: data)
            
            if let error = loginResponse.error {
                throw APIError.serverError(error)
            }
            
            guard let apiKey = loginResponse.apiKey else {
                throw APIError.serverError("No API key returned")
            }
            
            return apiKey
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func fetchApplications(apiKey: String) async throws -> [Application] {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "path", value: "applications"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        let request = URLRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let applications = try decoder.decode([Application].self, from: data)
            return applications
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func createApplication(apiKey: String, role: String, company: String, appliedAt: Date, source: String, salaryRange: String, location: String, url: String) async throws -> String {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "path", value: "applications"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        guard let requestURL = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let appliedAtString = dateFormatter.string(from: appliedAt)
        
        let requestBody = CreateApplicationRequest(
            role: role,
            company: company,
            appliedAt: appliedAtString,
            source: source,
            salaryRange: salaryRange,
            location: location,
            url: url
        )
        
        request.httpBody = try encoder.encode(requestBody)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let createResponse = try decoder.decode(CreateResponse.self, from: data)
            return createResponse.id
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func createActivity(apiKey: String, applicationId: String, type: ActivityType, occurredAt: Date, note: String) async throws -> String {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "path", value: "activities"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        guard let requestURL = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let occurredAtString = dateFormatter.string(from: occurredAt)
        
        let requestBody = CreateActivityRequest(
            applicationId: applicationId,
            type: type,
            occurredAt: occurredAtString,
            note: note
        )
        
        request.httpBody = try encoder.encode(requestBody)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let createResponse = try decoder.decode(CreateResponse.self, from: data)
            return createResponse.id
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func fetchNotifications(apiKey: String) async throws -> [AppNotification] {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "path", value: "activities/notifications"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let notifications = try decoder.decode([AppNotification].self, from: data)
            return notifications
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
