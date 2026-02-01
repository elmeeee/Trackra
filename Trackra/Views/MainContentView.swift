//
//  MainContentView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct MainContentView: View {
    @StateObject private var appState = AppState()
    @FocusState private var focusedField: FocusField?
    
    enum FocusField {
        case list
    }
    
    var body: some View {
        NavigationSplitView {
            ApplicationListView(appState: appState)
                .focused($focusedField, equals: .list)
        } detail: {
            if let application = appState.selectedApplication {
                ApplicationDetailView(appState: appState, application: application)
            } else {
                EmptyStateView(
                    icon: "arrow.left",
                    title: "No Selection",
                    message: "Select an application from the list to view details."
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
        .task {
            await appState.loadApplications()
        }
        .sheet(isPresented: $appState.showingAddApplication) {
            AddApplicationView(appState: appState)
        }
        .sheet(isPresented: $appState.showingAddActivity) {
            if let applicationId = appState.selectedApplicationId {
                AddActivityView(appState: appState, applicationId: applicationId)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    Task {
                        await appState.refresh()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh")
                .disabled(appState.isLoading)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .addApplication)) { _ in
            appState.showingAddApplication = true
        }
        .onAppear {
            focusedField = .list
        }
        .focusedSceneValue(\.appState, appState)
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
