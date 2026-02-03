//
//  ApplicationRow.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct ApplicationRow: View {
    let application: Application
    let isSelected: Bool
    let isProcessing: Bool
    var onActivityCreated: (ActivityType) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                // Title Section
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(application.role)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }

                    Text(application.company)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // Chips Section
                HStack(spacing: 6) {
                    // Last Stage Chip
                    ChipView(
                        text: lastStageLabel, color: .primary.opacity(0.8),
                        bgColor: Color(NSColor.controlBackgroundColor))

                    // Time Chip
                    ChipView(
                        text: timeAgoLabel, color: .secondary,
                        bgColor: Color(NSColor.controlBackgroundColor))
                }
            }

            Spacer()

            // Right Side: Status Badge
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(status: application.status, compact: false, showIcon: false)

                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    isSelected
                        ? Color.accentColor.opacity(0.08) : Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    isSelected ? Color.accentColor.opacity(0.3) : Color.clear,
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: isSelected ? 4 : 2, x: 0, y: 1)
        .contextMenu {
            Button("HR Screen", action: { onActivityCreated(.hrScreen) })
            Button("Recruiter Call", action: { onActivityCreated(.recruiterCall) })
            Button("Hiring Manager", action: { onActivityCreated(.hiringManagerInterview) })
            Button("Panel Interview", action: { onActivityCreated(.panelInterview) })
            Button("Onsite Interview", action: { onActivityCreated(.onsiteInterview) })
            Button("Interview Done", action: { onActivityCreated(.interviewDone) })
            Divider()
            Button("Technical Test", action: { onActivityCreated(.technicalTest) })
            Button("Take Home Test", action: { onActivityCreated(.takeHomeTest) })
            Divider()
            Button("Offer Received", action: { onActivityCreated(.offerReceived) })
            Button("Mark as Rejected", role: .destructive, action: { onActivityCreated(.rejected) })
        }
    }

    private var lastStageLabel: String {
        guard
            let latestActivity = application.activities.sorted(by: {
                if $0.occurredAt == $1.occurredAt {
                    return $0.type.sortOrder > $1.type.sortOrder
                }
                return $0.occurredAt > $1.occurredAt
            }).first
        else {
            return "Applied"
        }

        switch latestActivity.type {
        case .hrScreen: return "HR Screen"
        case .recruiterCall: return "Recruiter Call"
        case .hiringManagerInterview: return "Hiring Manager"
        case .panelInterview: return "Panel Interview"
        case .onsiteInterview: return "Onsite Interview"
        case .interviewScheduled: return "Interview Scheduled"
        case .interviewDone: return "Interview Done"
        case .technicalTest: return "Technical Test"
        case .takeHomeTest: return "Take Home Test"
        case .offerReceived: return "Offer"
        case .rejected: return "Rejected"
        case .note: return "Note"
        case .followUp: return "Follow Up"
        }
    }

    private var timeAgoLabel: String {
        let days = application.daysSinceLastActivity
        if days == 0 { return "Today" }
        if days == 1 { return "1 day ago" }
        return "\(days) days ago"
    }
}

struct ChipView: View {
    let text: String
    let color: Color
    let bgColor: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(bgColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
            )
    }
}
