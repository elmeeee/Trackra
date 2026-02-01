//
//  Activity.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation

struct Activity: Codable, Identifiable, Equatable {
    let id: String
    let applicationId: String
    let type: ActivityType
    let occurredAt: Date
    let note: String
    
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}
