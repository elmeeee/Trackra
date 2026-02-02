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
    @State private var searchText = ""
    
    var filteredApplications: [Application] {
        if searchText.count < 3 {
            return appState.sortedApplications
        }
        return appState.sortedApplications.filter { application in
            application.role.localizedCaseInsensitiveContains(searchText) ||
            application.company.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Applications")
                        .font(.system(size: 22, weight: .bold))
                    
                    if !appState.applications.isEmpty {
                        Text("\(appState.applications.count) total")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    appState.showingAddApplication = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .help("Add Application")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            Divider()
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
                
                TextField("Search by role or company...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            if appState.isLoading && appState.applications.isEmpty {
                SkeletonLoadingView()
            } else if let error = appState.error, appState.applications.isEmpty {
                ErrorView(error: error) {
                    Task {
                        await appState.refresh()
                    }
                }
            } else if appState.applications.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No Applications Yet",
                    message: "Start tracking your job search journey by adding your first application.",
                    actionTitle: "Add Application",
                    action: {
                        appState.showingAddApplication = true
                    }
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredApplications) { application in
                            ApplicationRow(
                                application: application,
                                isSelected: appState.selectedApplicationId == application.id
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    appState.selectedApplicationId = application.id
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
            }
        }
        .frame(minWidth: 320, idealWidth: 380)
    }
}
