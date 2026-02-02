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
    @FocusState private var focusedField: FocusField?
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        _appState = StateObject(wrappedValue: AppState(authManager: authManager))
    }
    
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
                    icon: "",
                    title: "No Selection",
                    message: "Select an application from the list to view details."
                )
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
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Menu {
                    if let email = authManager.userEmail {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(email)
                                .font(.system(size: 13, weight: .medium))
                            Text("Signed in")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Divider()
                    
                    Button(action: {
                        authManager.logout()
                    }) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .keyboardShortcut("q", modifiers: [.command, .shift])
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 20))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                        
                        if let email = authManager.userEmail {
                            Text(email)
                                .font(.system(size: 13, weight: .medium))
                                .lineLimit(1)
                        }
                    }
                }
                .help("Account")
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    Task {
                        await appState.refresh()
                    }
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .labelStyle(.iconOnly)
                }
                .help("Refresh applications")
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
