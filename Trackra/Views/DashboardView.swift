//
//  DashboardView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import Charts
import SwiftUI

struct DashboardView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var notificationManager = NotificationManager.shared
    @State private var showingNotifications = false
    @State private var showingLogoutConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Dashboard")
                        .font(.system(size: 28, weight: .bold))
                    Spacer()
                }
                .padding(.bottom, 4)

                // Key Metrics
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 160, maximum: .infinity), spacing: 16)],
                    spacing: 16
                ) {
                    SummaryCard(
                        title: "Total Applications",
                        value: "\(appState.applications.count)",
                        icon: "doc.text.fill",
                        color: .blue
                    )

                    SummaryCard(
                        title: "In Progress",
                        value: "\(inProgressCount)",
                        icon: "hourglass",
                        color: .orange
                    )

                    SummaryCard(
                        title: "Offers",
                        value: "\(offerCount)",
                        icon: "star.fill",
                        color: .yellow
                    )

                    SummaryCard(
                        title: "Success Rate",
                        value: successRate,
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green
                    )
                }

                // Charts & Insights
                HStack(alignment: .top, spacing: 16) {
                    // Main Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Application Status")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        if !statusData.isEmpty {
                            Chart(statusData, id: \.status) { item in
                                BarMark(
                                    x: .value("Count", item.count),
                                    y: .value("Status", item.status)
                                )
                                .foregroundStyle(by: .value("Status", item.status))
                                .cornerRadius(4)
                                .annotation(position: .trailing) {
                                    Text("\(item.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .chartLegend(.hidden)
                            .chartXAxis(.hidden)
                            .frame(minHeight: 250)
                        } else {
                            ContentUnavailableView("No Data", systemImage: "chart.bar")
                                .frame(height: 250)
                        }
                    }
                    .padding(20)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(maxWidth: .infinity)

                    // Side Panel (Activity & Actions)
                    VStack(spacing: 16) {
                        // Weekly Activity (Placeholder for visual balance)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Weekly Activity")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Chart {
                                BarMark(x: .value("Day", "Mon"), y: .value("Activity", 2))
                                BarMark(x: .value("Day", "Tue"), y: .value("Activity", 5))
                                BarMark(x: .value("Day", "Wed"), y: .value("Activity", 3))
                                BarMark(x: .value("Day", "Thu"), y: .value("Activity", 1))
                                BarMark(x: .value("Day", "Fri"), y: .value("Activity", 4))
                            }
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisValueLabel()
                                }
                            }
                            .chartYAxis(.hidden)
                            .frame(height: 120)
                        }
                        .padding(20)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Action Items
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Action Items")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            if followUpCount > 0 {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.red)

                                    VStack(alignment: .leading) {
                                        Text("\(followUpCount) Follow-ups")
                                            .font(.headline)
                                        Text("Recommended based on inactivity")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(12)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                            } else {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                    Text("You're all caught up!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .frame(width: 280)
                }
            }
            .padding(24)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingNotifications.toggle() }) {
                    ZStack {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14))

                        if notificationManager.unreadCount > 0 {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .popover(isPresented: $showingNotifications) {
                    NotificationPanelView(notificationManager: notificationManager)
                }
                .help("Notifications")
            }

            if let email = appState.authManager.userEmail {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Text(email)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Divider()

                        Button("Sign Out", role: .destructive) {
                            showingLogoutConfirmation = true
                        }
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.system(size: 16))
                    }
                    .confirmationDialog("Sign Out?", isPresented: $showingLogoutConfirmation) {
                        Button("Sign Out", role: .destructive) {
                            appState.authManager.logout()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to sign out?")
                    }
                    .help("Account")
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var inProgressCount: Int {
        appState.applications.filter {
            $0.status != .rejected && $0.status != .offering && $0.status != .withdrawn
        }.count
    }

    private var offerCount: Int {
        appState.applications.filter { $0.status == .offering }.count
    }

    private var followUpCount: Int {
        appState.applications.filter { $0.status == .noResponse }.count
    }

    private var successRate: String {
        let total = appState.applications.count
        guard total > 0 else { return "0%" }
        let offers = Double(offerCount)
        let rate = (offers / Double(total)) * 100
        return String(format: "%.1f%%", rate)
    }

    private struct StatusData {
        let status: String
        let count: Int
    }

    private var statusData: [StatusData] {
        let grouped = Dictionary(grouping: appState.applications, by: { $0.status })
        return grouped.map { key, value in
            StatusData(status: key.displayName, count: value.count)
        }.sorted { $0.count > $1.count }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .padding(8)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
