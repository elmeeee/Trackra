//
//  ApplicationStatus.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation

enum ApplicationStatus: String, Codable, CaseIterable {
    case applied
    case technicalTest = "technical_test"
    case interview
    case offering
    case rejected
    case withdrawn
    case noResponse = "no_response"

    var displayName: String {
        switch self {
        case .applied: return "Applied"
        case .technicalTest: return "Technical"
        case .interview: return "Interview"
        case .offering: return "Offer"
        case .rejected: return "Rejected"
        case .withdrawn: return "Withdrawn"
        case .noResponse: return "No Response"
        }
    }

    var color: String {
        switch self {
        case .applied: return "blue"
        case .technicalTest: return "purple"
        case .interview: return "indigo"
        case .offering: return "green"
        case .rejected: return "red"
        case .withdrawn: return "gray"
        case .noResponse: return "orange"
        }
    }
}
