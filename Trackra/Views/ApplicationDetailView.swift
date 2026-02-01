//
//  ApplicationDetailView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct ApplicationDetailView: View {
    @ObservedObject var appState: AppState
    let application: Application
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                
                Divider()
                    .padding(.vertical, 20)
                
                metadataSection
                
                if application.status == .noResponse {
                    followUpBanner
                        .padding(.top, 20)
                }
                
                Divider()
                    .padding(.vertical, 20)
                
                timelineSection
            }
            .padding(24)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(application.role)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "building.2")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(application.company)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                quickActionsMenu
            }
            
            HStack(spacing: 12) {
                StatusBadge(status: application.status, compact: false, showIcon: true)
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(application.daysSinceLastActivity) days ago")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                if application.status == .noResponse {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text("Needs follow-up")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    private var quickActionsMenu: some View {
        Menu {
            Button(action: {
                appState.showingAddActivity = true
            }) {
                Label("Interview Scheduled", systemImage: "calendar.badge.clock")
            }
            
            Button(action: {
                Task {
                    await appState.createActivity(
                        applicationId: application.id,
                        type: .interviewDone,
                        occurredAt: Date(),
                        note: ""
                    )
                }
            }) {
                Label("Interview Done", systemImage: "checkmark.circle")
            }
            
            Button(action: {
                Task {
                    await appState.createActivity(
                        applicationId: application.id,
                        type: .followUp,
                        occurredAt: Date(),
                        note: ""
                    )
                }
            }) {
                Label("Follow Up", systemImage: "arrow.turn.up.right")
            }
            
            Divider()
            
            Button(action: {
                Task {
                    await appState.createActivity(
                        applicationId: application.id,
                        type: .offerReceived,
                        occurredAt: Date(),
                        note: ""
                    )
                }
            }) {
                Label("Offer Received", systemImage: "gift")
            }
            
            Button(action: {
                Task {
                    await appState.createActivity(
                        applicationId: application.id,
                        type: .rejected,
                        occurredAt: Date(),
                        note: ""
                    )
                }
            }) {
                Label("Rejection", systemImage: "xmark.circle")
            }
            
            Divider()
            
            Button(action: {
                appState.showingAddActivity = true
            }) {
                Label("Add Note", systemImage: "note.text")
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 13, weight: .semibold))
                Text("Quick Actions")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.accentColor)
            .clipShape(Capsule())
        }
        .menuStyle(.borderlessButton)
    }
    
    private var metadataSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                metadataCard(
                    icon: "calendar",
                    title: "Applied",
                    value: formatDate(application.appliedAt)
                )
                
                if !application.location.isEmpty {
                    metadataCard(
                        icon: "location.fill",
                        title: "Location",
                        value: application.location
                    )
                }
            }
            
            if !application.salaryRange.isEmpty || !application.source.isEmpty {
                HStack(spacing: 20) {
                    if !application.salaryRange.isEmpty {
                        metadataCard(
                            icon: "dollarsign.circle.fill",
                            title: "Salary Range",
                            value: application.salaryRange
                        )
                    }
                    
                    if !application.source.isEmpty {
                        metadataCard(
                            icon: "link.circle.fill",
                            title: "Source",
                            value: application.source
                        )
                    }
                }
            }
        }
    }
    
    private func metadataCard(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var followUpBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Follow-up Recommended")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("No response for 14+ days. Consider reaching out.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await appState.createActivity(
                        applicationId: application.id,
                        type: .followUp,
                        occurredAt: Date(),
                        note: ""
                    )
                }
            }) {
                Text("Add Follow-up")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Timeline")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("\(application.activities.count + 1) events")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            ActivityTimelineView(application: application)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
