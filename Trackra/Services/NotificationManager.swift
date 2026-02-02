//
//  NotificationManager.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation
import UserNotifications
import SwiftUI
import Combine

final class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    @Published var hasPermission: Bool = false
    
    private let center = UNUserNotificationCenter.current()
    private var pollingTimer: Timer?
    private var apiClient: APIClientProtocol?
    private var authManager: AuthenticationManager?
    
    private override init() {
        super.init()
        loadStoredNotifications()
        center.delegate = self
    }
    
    func configure(apiClient: APIClientProtocol, authManager: AuthenticationManager) {
        self.apiClient = apiClient
        self.authManager = authManager
    }
    
    func requestPermission() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                hasPermission = granted
            }
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        } catch {
            print("Error requesting notification permission: \(error)")
        }
    }
    
    func startPolling() {
        stopPolling()
        
        // Initial check
        Task {
            await checkForNotifications()
        }
        
        // Poll every 5 minutes (300 seconds)
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkForNotifications()
            }
        }
    }
    
    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    func checkForNotifications() async {
        guard let apiClient = apiClient,
              let authManager = authManager,
              let apiKey = authManager.getApiKey() else {
            return
        }
        
        do {
            let newNotifications = try await apiClient.fetchNotifications(apiKey: apiKey)
            
            // Filter out notifications we've already seen
            let unseenNotifications = newNotifications.filter { newNotif in
                !notifications.contains { $0.id == newNotif.id }
            }
            
            // Schedule local notifications for new items
            for notification in unseenNotifications {
                await scheduleLocalNotification(for: notification)
            }
            
            // Update stored notifications
            await MainActor.run {
                notifications = newNotifications + notifications
                updateUnreadCount()
                saveNotifications()
                updateAppBadge()
            }
            
        } catch {
            print("Error fetching notifications: \(error)")
        }
    }
    
    private func scheduleLocalNotification(for notification: AppNotification) async {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = notification.type.title
        content.body = notification.note
        content.sound = .default
        content.badge = NSNumber(value: unreadCount + 1)
        content.userInfo = ["notificationId": notification.id]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Scheduled notification: \(notification.type.title)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    @MainActor
    func markAsRead(_ notificationId: String) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            updateUnreadCount()
            saveNotifications()
            updateAppBadge()
        }
    }
    
    @MainActor
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        updateUnreadCount()
        saveNotifications()
        updateAppBadge()
    }
    
    @MainActor
    func clearAll() {
        notifications.removeAll()
        unreadCount = 0
        saveNotifications()
        updateAppBadge()
        center.removeAllDeliveredNotifications()
    }
    
    @MainActor
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    @MainActor
    private func updateAppBadge() {
        center.setBadgeCount(unreadCount) { error in
            if let error = error {
                print("Error setting badge: \(error)")
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: "savedNotifications")
        }
    }
    
    private func loadStoredNotifications() {
        if let data = UserDefaults.standard.data(forKey: "savedNotifications"),
           let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) {
            notifications = decoded
            updateUnreadCount()
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        let notificationId = response.notification.request.content.userInfo["notificationId"] as? String
        
        Task { @MainActor in
            if let id = notificationId {
                self.markAsRead(id)
            }
        }
        
        completionHandler()
    }
}
