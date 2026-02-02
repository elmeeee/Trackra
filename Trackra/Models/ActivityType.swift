//
//  ActivityType.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation

enum ActivityType: String, Codable, CaseIterable {
    case hrScreen = "hr_screen"
    case recruiterCall = "recruiter_call"
    case hiringManagerInterview = "hiring_manager_interview"
    case panelInterview = "panel_interview"
    case onsiteInterview = "onsite_interview"
    case interviewScheduled = "interview_scheduled"
    case interviewDone = "interview_done"
    case technicalTest = "technical_test"
    case takeHomeTest = "take_home_test"
    case offerReceived = "offer_received"
    case rejected
    case note
    case followUp = "follow_up"

    var displayName: String {
        switch self {
        case .hrScreen: return "HR Screen"
        case .recruiterCall: return "Recruiter Call"
        case .hiringManagerInterview: return "Hiring Manager"
        case .panelInterview: return "Panel Interview"
        case .onsiteInterview: return "Onsite Interview"
        case .interviewScheduled: return "Interview Scheduled"
        case .interviewDone: return "Interview Done"
        case .technicalTest: return "Technical Test"
        case .takeHomeTest: return "Take Home Test"
        case .offerReceived: return "Offer Received"
        case .rejected: return "Rejected"
        case .note: return "Note"
        case .followUp: return "Follow Up"
        }
    }

    var icon: String {
        switch self {
        case .hrScreen: return "person.crop.circle"
        case .recruiterCall: return "phone"
        case .hiringManagerInterview: return "person.bust"
        case .panelInterview: return "person.3"
        case .onsiteInterview: return "building.2"
        case .interviewScheduled: return "calendar.badge.clock"
        case .interviewDone: return "checkmark.circle"
        case .technicalTest: return "laptopcomputer"
        case .takeHomeTest: return "doc.text"
        case .offerReceived: return "gift"
        case .rejected: return "xmark.circle"
        case .note: return "note.text"
        case .followUp: return "arrow.turn.up.right"
        }
    }
}
