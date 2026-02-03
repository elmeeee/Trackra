//
//  Application.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation

struct Application: Codable, Identifiable, Equatable {
    let id: String
    let role: String
    let company: String
    let appliedAt: Date
    let source: String
    let salaryRange: String
    let location: String
    let url: String
    let createdAt: Date
    var status: ApplicationStatus
    let daysSinceLastActivity: Int
    var activities: [Activity]

    static func == (lhs: Application, rhs: Application) -> Bool {
        lhs.id == rhs.id
    }
}
