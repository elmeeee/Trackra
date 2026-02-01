//
//  CreateActivityRequest.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation

struct CreateActivityRequest: Codable {
    let applicationId: String
    let type: ActivityType
    let occurredAt: String
    let note: String
}
