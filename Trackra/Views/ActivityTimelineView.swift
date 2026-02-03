//
//  ActivityTimelineView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct ActivityTimelineView: View {
    let application: Application

    private var sortedActivities: [Activity] {
        // Sort by occurredAt descending (Result: Newest First)
        // If dates are equal, we can't guarantee order without another property,
        // but typically the insertion order (which stable sort preserves) or ID might define it.
        // Assuming user adds activities in order, Latest added = Newest.
        // If the array comes from backend, it might be in arbitrary order.
        return application.activities.sorted {
            // Use > for descending (Newest Top)
            if $0.occurredAt == $1.occurredAt {
                // Determine equality fallback?
                // For now just rely on >
                return false
            }
            return $0.occurredAt > $1.occurredAt
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sortedActivities.enumerated()), id: \.element.id) { index, activity in
                timelineItem(
                    icon: activity.type.icon,
                    title: activity.type.displayName,
                    date: activity.occurredAt,
                    note: activity.note,
                    color: activityColor(for: activity.type),
                    isLast: false
                )
            }

            timelineItem(
                icon: "paperplane.fill",
                title: "Application Submitted",
                date: application.appliedAt,
                note: "",
                color: .blue,
                isLast: true
            )
        }
    }

    private func timelineItem(
        icon: String, title: String, date: Date, note: String, color: Color, isLast: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 10, height: 10)

                    Circle()
                        .strokeBorder(color.opacity(0.3), lineWidth: 4)
                        .frame(width: 20, height: 20)
                }
                .frame(height: 32)

                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 2)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(color)

                            Text(title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        Text(formatDate(date))
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)

                        if !note.isEmpty {
                            Text(note)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.primary)
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                )
            }
            .padding(.bottom, isLast ? 0 : 12)
        }
    }

    private func activityColor(for type: ActivityType) -> Color {
        switch type {
        case .hrScreen, .recruiterCall:
            return .blue
        case .hiringManagerInterview, .panelInterview, .onsiteInterview, .interviewScheduled:
            return .purple
        case .technicalTest, .takeHomeTest:
            return .indigo
        case .interviewDone:
            return .green
        case .offerReceived:
            return .green
        case .rejected:
            return .red
        case .note:
            return .gray
        case .followUp:
            return .orange
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
