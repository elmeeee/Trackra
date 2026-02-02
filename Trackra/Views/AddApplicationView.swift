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
    @State private var source = "LinkedIn"
    @State private var salaryRange = ""
    @State private var location = ""
    @State private var url = ""
    @State private var isSubmitting = false
    
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
                    Picker("Source (optional)", selection: $source) {
                        Text("LinkedIn").tag("LinkedIn")
                        Text("Indeed").tag("Indeed")
                        Text("Glassdoor").tag("Glassdoor")
                        Text("Company Portal").tag("Company Portal")
                        Text("Job Portal").tag("Job Portal")
                        Text("Referral").tag("Referral")
                        Text("Recruiter").tag("Recruiter")
                        Text("Other").tag("Other")
                    }
                    TextField("Salary Range (optional)", text: $salaryRange)
                    TextField("Location (optional)", text: $location)
                    TextField("URL (optional)", text: $url)
                }
            }
            .formStyle(.grouped)
            .disabled(isSubmitting)
            
            Divider()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .disabled(isSubmitting)
                
                Spacer()
                
                Button(action: {
                    Task {
                        isSubmitting = true
                        await appState.createApplication(
                            role: role,
                            company: company,
                            appliedAt: appliedAt,
                            source: source,
                            salaryRange: salaryRange,
                            location: location,
                            url: url
                        )
                        isSubmitting = false
                        if appState.error == nil {
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .controlSize(.small)
                                .padding(.trailing, 4)
                        }
                        Text(isSubmitting ? "Adding..." : "Add Application")
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(role.isEmpty || company.isEmpty || isSubmitting)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
    }
}
