//
//  ApplicationListView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct ApplicationListView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var notificationManager = NotificationManager.shared
    @State private var searchText = ""
    @State private var selectedStatus: ApplicationStatus? = nil
    @State private var showingNotifications = false
    @State private var showingLogoutConfirmation = false

    var filteredApplications: [Application] {
        let baseApps = appState.sortedApplications
        let statusFiltered =
            selectedStatus == nil ? baseApps : baseApps.filter { $0.status == selectedStatus }

        if searchText.count < 3 {
            return statusFiltered
        }
        return statusFiltered.filter { application in
            application.role.localizedCaseInsensitiveContains(searchText)
                || application.company.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            List(
                selection: Binding(
                    get: { appState.selectedApplicationId },
                    set: { appState.selectedApplicationId = $0 }
                )
            ) {
                ForEach(filteredApplications) { application in
                    ApplicationRow(
                        application: application,
                        isSelected: appState.selectedApplicationId == application.id,
                        isProcessing: appState.processingApplicationId == application.id
                    ) { activityType in
                        appState.selectedApplicationId = application.id
                        appState.activityTypeToAdd = activityType
                        appState.showingAddActivity = true
                    }
                    .tag(application.id)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                }
            }
            .listStyle(.plain)
            .searchable(
                text: $searchText, placement: .automatic, prompt: "Search by role or company..."
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        Task {
                            await appState.refresh()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(appState.isLoading ? 360 : 0))
                            .animation(
                                appState.isLoading
                                    ? Animation.linear(duration: 1.0).repeatForever(
                                        autoreverses: false)
                                    : .default,
                                value: appState.isLoading
                            )
                    }
                    .help("Refresh")
                    .disabled(appState.isLoading)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        appState.showingAddApplication = true
                    }) {
                        Label("Add Application", systemImage: "plus")
                    }
                    .help("New Application (⌘N)")
                    .keyboardShortcut("n", modifiers: .command)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNotifications.toggle() }) {
                        ZStack {
                            Image(systemName: "bell.fill")

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
                        }
                        .confirmationDialog("Sign Out?", isPresented: $showingLogoutConfirmation) {
                            Button("Sign Out", role: .destructive) {
                                appState.authManager.logout()
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                        .help("Account")
                    }
                }
            }
            .navigationTitle("Applications")

            if appState.isLoading && appState.applications.isEmpty {
                SkeletonLoadingView()
            } else if appState.applications.isEmpty && !appState.isLoading {
                ContentUnavailableView {
                    Label("No Applications", systemImage: "tray")
                } description: {
                    Text("Start tracking by adding your first application.")
                } actions: {
                    Button("Add Application") { appState.showingAddApplication = true }
                }
            }
        }
        .frame(minWidth: 320, idealWidth: 380)
    }

    private func colorForStatus(_ status: ApplicationStatus) -> Color {
        switch status {
        case .applied: return .blue
        case .technicalTest: return .purple
        case .interview: return .indigo
        case .offering: return .green
        case .rejected: return .red
        case .withdrawn: return .gray
        case .noResponse: return .orange
        }
    }
}
