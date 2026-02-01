//
//  AddApplicationView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct AddApplicationView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var role = ""
    @State private var company = ""
    @State private var appliedAt = Date()
    @State private var source = ""
    @State private var salaryRange = ""
    @State private var location = ""
    @State private var url = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add Application")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            Form {
                Section {
                    TextField("Role", text: $role)
                    TextField("Company", text: $company)
                    DatePicker("Applied At", selection: $appliedAt, displayedComponents: .date)
                }
                
                Section {
                    TextField("Source (optional)", text: $source)
                    TextField("Salary Range (optional)", text: $salaryRange)
                    TextField("Location (optional)", text: $location)
                    TextField("URL (optional)", text: $url)
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Add Application") {
                    Task {
                        await appState.createApplication(
                            role: role,
                            company: company,
                            appliedAt: appliedAt,
                            source: source,
                            salaryRange: salaryRange,
                            location: location,
                            url: url
                        )
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(role.isEmpty || company.isEmpty)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
    }
}
