//
//  ActivityType.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation

enum ActivityType: String, Codable, CaseIterable {
    case interviewScheduled = "interview_scheduled"
    case interviewDone = "interview_done"
    case offerReceived = "offer_received"
    case rejected
    case note
    case followUp = "follow_up"
    
    var displayName: String {
        switch self {
        case .interviewScheduled: return "Interview Scheduled"
        case .interviewDone: return "Interview Done"
        case .offerReceived: return "Offer Received"
        case .rejected: return "Rejected"
        case .note: return "Note"
        case .followUp: return "Follow Up"
        }
    }
    
    var icon: String {
        switch self {
        case .interviewScheduled: return "calendar.badge.clock"
        case .interviewDone: return "checkmark.circle"
        case .offerReceived: return "gift"
        case .rejected: return "xmark.circle"
        case .note: return "note.text"
        case .followUp: return "arrow.turn.up.right"
        }
    }
}
