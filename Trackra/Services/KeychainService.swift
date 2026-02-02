//
//  KeychainService.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()
    
    private let service = "co.kamy.Trackra"
    private let apiKeyAccount = "apiKey"
    private let emailAccount = "userEmail"
    
    private init() {}
    
    // MARK: - API Key
    
    func saveApiKey(_ apiKey: String) -> Bool {
        return save(apiKey, account: apiKeyAccount)
    }
    
    func getApiKey() -> String? {
        return retrieve(account: apiKeyAccount)
    }
    
    func deleteApiKey() -> Bool {
        return delete(account: apiKeyAccount)
    }
    
    // MARK: - Email
    
    func saveEmail(_ email: String) -> Bool {
        return save(email, account: emailAccount)
    }
    
    func getEmail() -> String? {
        return retrieve(account: emailAccount)
    }
    
    func deleteEmail() -> Bool {
        return delete(account: emailAccount)
    }
    
    // MARK: - Clear All
    
    func clearAll() -> Bool {
        let apiKeyDeleted = deleteApiKey()
        let emailDeleted = deleteEmail()
        return apiKeyDeleted && emailDeleted
    }
    
    // MARK: - Private Methods
    
    private func save(_ value: String, account: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // Delete existing item first
        _ = delete(account: account)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func retrieve(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func delete(account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
