//
//  StatusBadge.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct StatusBadge: View {
    let status: ApplicationStatus
    let compact: Bool
    let showIcon: Bool
    
    init(status: ApplicationStatus, compact: Bool = false, showIcon: Bool = true) {
        self.status = status
        self.compact = compact
        self.showIcon = showIcon
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if showIcon {
                Image(systemName: iconName)
                    .font(.system(size: compact ? 10 : 11, weight: .semibold))
            }
            
            Text(status.displayName)
                .font(.system(size: compact ? 11 : 12, weight: .semibold))
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .background(backgroundColor.opacity(0.15))
        .foregroundColor(backgroundColor)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(backgroundColor.opacity(0.3), lineWidth: 0.5)
        )
    }
    
    private var iconName: String {
        switch status {
        case .applied:
            return "paperplane.fill"
        case .interview:
            return "person.2.fill"
        case .offering:
            return "gift.fill"
        case .rejected:
            return "xmark.circle.fill"
        case .noResponse:
            return "clock.fill"
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .applied:
            return .blue
        case .interview:
            return .purple
        case .offering:
            return .green
        case .rejected:
            return .red
        case .noResponse:
            return .orange
        }
    }
}
