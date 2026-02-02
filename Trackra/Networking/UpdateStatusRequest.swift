//
//  UpdateStatusRequest.swift
//  Trackra
//
//  Created by Elmee on 02/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Foundation

struct UpdateStatusRequest: Codable {
    let applicationId: String
    let status: String
}
