//
//  MainContentView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct MainContentView: View {
    let authManager: AuthenticationManager
    @StateObject private var appState: AppState
    @StateObject private var notificationManager = NotificationManager.shared
    @FocusState private var focusedField: FocusField?
    @State private var showingNotifications = false
    @State private var showingLogoutConfirmation = false

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        _appState = StateObject(wrappedValue: AppState(authManager: authManager))
    }

    enum SidebarItem: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case applications = "Applications"
        var id: String { rawValue }
    }

    enum FocusField {
        case list
    }

    @State private var sidebarSelection: SidebarItem? = .applications

    var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            switch sidebarSelection {
            case .dashboard:
                DashboardView(appState: appState)
                    .frame(minWidth: 600)  // Ensure dashboard has space
            case .applications, .none:
                applicationsSplitView
            }
        }
        .navigationSplitViewStyle(.balanced)
        .task {
            if authManager.authState == .authenticated {
                await appState.loadApplications()
            }
        }
        .onChange(of: authManager.authState) { oldValue, newValue in
            if newValue == .authenticated {
                Task {
                    await appState.loadApplications()
                }
            }
        }
        .sheet(isPresented: $appState.showingAddApplication) {
            AddApplicationView(appState: appState)
        }
        .sheet(isPresented: $appState.showingAddActivity) {
            if let applicationId = appState.selectedApplicationId {
                AddActivityView(appState: appState, applicationId: applicationId)
            }
        }

        .onReceive(NotificationCenter.default.publisher(for: .addApplication)) { _ in
            appState.showingAddApplication = true
        }
        .onAppear {
            focusedField = .list
            setupNotifications()
        }
        .onDisappear {
            notificationManager.stopPolling()
        }
        .focusedSceneValue(\.appState, appState)
        .alert(
            "Success",
            isPresented: Binding(
                get: { appState.successMessage != nil },
                set: { _ in appState.successMessage = nil }
            )
        ) {
            Button("OK", role: .cancel) {
                appState.successMessage = nil
            }
        } message: {
            if let message = appState.successMessage {
                Text(message)
            }
        }
        .alert("Sign Out", isPresented: $showingLogoutConfirmation) {
            Button("Cancel", role: .cancel) {
                showingLogoutConfirmation = false
            }
            Button("Sign Out", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    @ViewBuilder
    private var sidebarView: some View {
        List(SidebarItem.allCases, selection: $sidebarSelection) { item in
            NavigationLink(value: item) {
                Label(
                    item.rawValue,
                    systemImage: item.id == SidebarItem.dashboard.id
                        ? "square.grid.2x2" : "list.bullet")
            }
        }
        .navigationTitle("Trackra")
        .navigationSplitViewColumnWidth(min: 220, ideal: 220, max: 220)
    }

    @ViewBuilder
    private var applicationsSplitView: some View {
        NavigationStack {
            ApplicationListView(appState: appState)
                .navigationDestination(
                    isPresented: Binding(
                        get: { appState.selectedApplicationId != nil },
                        set: { if !$0 { appState.selectedApplicationId = nil } }
                    )
                ) {
                    if let application = appState.selectedApplication {
                        ApplicationDetailView(appState: appState, application: application)
                    }
                }
        }
    }

    private func setupNotifications() {
        notificationManager.configure(apiClient: APIClient(), authManager: authManager)

        Task {
            await notificationManager.requestPermission()
            notificationManager.startPolling()
        }
    }
}

extension FocusedValues {
    struct AppStateKey: FocusedValueKey {
        typealias Value = AppState
    }

    var appState: AppState? {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}
