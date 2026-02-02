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
    @State private var isProcessingQuickAction = false
    @State private var showingLogoutConfirmation = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                
                Divider()
                    .padding(.vertical, 20)
                
                metadataSection
                
                Divider()
                    .padding(.vertical, 20)
                
                statusAndActionsSection
                
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
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    appState.selectedApplicationId = nil
                }) {
                    Label("Back", systemImage: "chevron.left")
                        .labelStyle(.titleAndIcon)
                }
            }
        }
        .navigationTitle(application.role)
        .navigationSubtitle(application.company)
        .alert("Sign Out", isPresented: $showingLogoutConfirmation) {
            Button("Cancel", role: .cancel) {
                showingLogoutConfirmation = false
            }
            Button("Sign Out", role: .destructive) {
                appState.authManager.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Application", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                showingDeleteConfirmation = false
            }
            Button("Delete", role: .destructive) {
                Task {
                    await appState.deleteApplication(applicationId: application.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete this application? This action cannot be undone and will also delete all related activities.")
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(application.role)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(application.company)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                quickActionsMenu
            }
            
            HStack(spacing: 10) {
                StatusBadge(status: application.status, compact: false, showIcon: true)
                
                if application.status != .rejected {
                    Divider()
                        .frame(height: 20)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(application.daysSinceLastActivity) days ago")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                if application.status == .noResponse {
                    Divider()
                        .frame(height: 20)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text("Needs follow-up")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.12))
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
    
    private var quickActionsMenu: some View {
        Menu {
            Button(action: {
                appState.showingAddActivity = true
            }) {
                Label("Interview Scheduled", systemImage: "calendar.badge.clock")
            }
            .disabled(isProcessingQuickAction)
            
            Button(action: {
                handleQuickAction(.interviewDone)
            }) {
                Label("Interview Done", systemImage: "checkmark.circle")
            }
            .disabled(isProcessingQuickAction)
            
            Button(action: {
                handleQuickAction(.followUp)
            }) {
                Label("Follow Up", systemImage: "arrow.turn.up.right")
            }
            .disabled(isProcessingQuickAction)
            
            Divider()
            
            Button(action: {
                handleQuickAction(.offerReceived)
            }) {
                Label("Offer Received", systemImage: "gift")
            }
            .disabled(isProcessingQuickAction)
            
            Button(action: {
                handleQuickAction(.rejected)
            }) {
                Label("Rejection", systemImage: "xmark.circle")
            }
            .disabled(isProcessingQuickAction)
            
            Divider()
            
            Button(action: {
                appState.showingAddActivity = true
            }) {
                Label("Add Note", systemImage: "note.text")
            }
            .disabled(isProcessingQuickAction)
            
            Divider()
            
            Button(role: .destructive, action: {
                showingDeleteConfirmation = true
            }) {
                Label("Delete Application", systemImage: "trash")
            }
        } label: {
            HStack(spacing: 6) {
                if isProcessingQuickAction {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(isProcessingQuickAction ? "Processing..." : "Quick Actions")
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
    
    private var statusAndActionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status")
                        .font(.system(size: 20, weight: .bold))
                }
                
                Spacer()
            }
            
            HStack {
                StatusBadge(status: application.status, compact: false, showIcon: true)
                
                Spacer()
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
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
    
    private func handleQuickAction(_ activityType: ActivityType) {
        Task {
            isProcessingQuickAction = true
            await appState.createActivity(
                applicationId: application.id,
                type: activityType,
                occurredAt: Date(),
                note: ""
            )
            isProcessingQuickAction = false
        }
    }
}
