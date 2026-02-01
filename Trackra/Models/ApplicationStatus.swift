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
    case interview
    case offering
    case rejected
    case noResponse = "no_response"
    
    var displayName: String {
        switch self {
        case .applied: return "Applied"
        case .interview: return "Interview"
        case .offering: return "Offering"
        case .rejected: return "Rejected"
        case .noResponse: return "No Response"
        }
    }
    
    var color: String {
        switch self {
        case .applied: return "blue"
        case .interview: return "purple"
        case .offering: return "green"
        case .rejected: return "red"
        case .noResponse: return "orange"
        }
    }
}
