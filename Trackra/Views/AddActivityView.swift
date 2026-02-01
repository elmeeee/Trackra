//
//  AddActivityView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct AddActivityView: View {
    @ObservedObject var appState: AppState
    let applicationId: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var activityType: ActivityType = .note
    @State private var occurredAt = Date()
    @State private var note = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add Activity")
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
                    Picker("Activity Type", selection: $activityType) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    
                    DatePicker("Occurred At", selection: $occurredAt, displayedComponents: .date)
                }
                
                Section {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                        .font(.body)
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
                
                Button("Add Activity") {
                    Task {
                        await appState.createActivity(
                            applicationId: applicationId,
                            type: activityType,
                            occurredAt: occurredAt,
                            note: note
                        )
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }
}
