//
//  AppNotification.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation

struct AppNotification: Codable, Identifiable {
    let id: String
    let applicationId: String
    let type: NotificationType
    let occurredAt: Date
    let note: String
    var isRead: Bool = false
    
    enum NotificationType: String, Codable {
        case rejected
        case noResponse = "no_response"
        
        var title: String {
            switch self {
            case .rejected:
                return "Application Rejected"
            case .noResponse:
                return "No Response"
            }
        }
        
        var icon: String {
            switch self {
            case .rejected:
                return "xmark.circle.fill"
            case .noResponse:
                return "clock.badge.exclamationmark.fill"
            }
        }
        
        var color: String {
            switch self {
            case .rejected:
                return "red"
            case .noResponse:
                return "orange"
            }
        }
    }
}
