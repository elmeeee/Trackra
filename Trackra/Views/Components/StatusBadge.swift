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
        case .technicalTest:
            return "laptopcomputer"
        case .interview:
            return "person.2.fill"
        case .offering:
            return "gift.fill"
        case .rejected:
            return "xmark.circle.fill"
        case .withdrawn:
            return "arrow.uturn.backward.circle.fill"
        case .noResponse:
            return "clock.badge.exclamationmark.fill"
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .applied:
            return .blue
        case .technicalTest:
            return .purple
        case .interview:
            return .indigo
        case .offering:
            return .green
        case .rejected, .withdrawn:
            return .gray
        case .noResponse:
            return .orange
        }
    }
}
