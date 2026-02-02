//
//  NotificationPanelView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct NotificationPanelView: View {
    @ObservedObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notifications")
                        .font(.system(size: 20, weight: .semibold))
                    
                    if notificationManager.unreadCount > 0 {
                        Text("\(notificationManager.unreadCount) unread")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if !notificationManager.notifications.isEmpty {
                    Menu {
                        Button(action: {
                            notificationManager.markAllAsRead()
                        }) {
                            Label("Mark All as Read", systemImage: "checkmark.circle")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            notificationManager.clearAll()
                        }) {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                    .menuStyle(.borderlessButton)
                }
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            
            Divider()
            
            // Notification List
            if notificationManager.notifications.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(notificationManager.notifications) { notification in
                            NotificationRow(
                                notification: notification,
                                onTap: {
                                    notificationManager.markAsRead(notification.id)
                                }
                            )
                            
                            if notification.id != notificationManager.notifications.last?.id {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 400, height: 500)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Notifications")
                .font(.system(size: 18, weight: .semibold))
            
            Text("You're all caught up!")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: notification.type.icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(notification.type.title)
                            .font(.system(size: 14, weight: notification.isRead ? .regular : .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.note)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(timeAgo(from: notification.occurredAt))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(notification.isRead ? Color.clear : Color.accentColor.opacity(0.05))
        }
        .buttonStyle(.plain)
    }
    
    private var iconColor: Color {
        switch notification.type.color {
        case "red": return .red
        case "orange": return .orange
        default: return .blue
        }
    }
    
    private var iconBackgroundColor: Color {
        switch notification.type.color {
        case "red": return Color.red.opacity(0.15)
        case "orange": return Color.orange.opacity(0.15)
        default: return Color.blue.opacity(0.15)
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}
