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
    @State private var isSubmitting = false

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
                .disabled(isSubmitting)

                Spacer()

                Button(action: {
                    isSubmitting = true
                    Task {
                        await appState.createActivity(
                            applicationId: applicationId,
                            type: activityType,
                            occurredAt: occurredAt,
                            note: note
                        )
                        isSubmitting = false
                        dismiss()
                    }
                }) {
                    if isSubmitting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Add Activity")
                    }
                }
                .disabled(isSubmitting)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .onAppear {
            if let defaultType = appState.activityTypeToAdd {
                activityType = defaultType
                appState.activityTypeToAdd = nil
            }
        }
    }
}
