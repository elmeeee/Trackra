//
//  CreateApplicationRequest.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation

struct CreateApplicationRequest: Codable {
    let role: String
    let company: String
    let appliedAt: String
    let source: String
    let salaryRange: String
    let location: String
    let url: String
}
