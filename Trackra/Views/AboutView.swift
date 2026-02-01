//
//  AboutView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                            .resizable()
                            .frame(width: 128, height: 128)
                            .cornerRadius(28)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                        
                        VStack(spacing: 8) {
                            Text("Trackra")
                                .font(.system(size: 32, weight: .bold))
                            
                            Text("Career Companion for macOS")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("Version 1.0 (1)")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 32)
                    
                    Divider()
                        .padding(.horizontal, 32)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        sectionHeader("About This App")
                        
                        Text("Trackra is a native macOS application designed to help you track job applications and manage your career journey. Built with SwiftUI and modern Swift concurrency, it provides a seamless experience for organizing applications, tracking interview progress, and managing follow-ups.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        sectionHeader("Developer")
                        
                        VStack(alignment: .leading, spacing: 12) {
                            infoRow(icon: "person.fill", label: "Developer", value: "Your Name")
                            infoRow(icon: "envelope.fill", label: "Email", value: "your.email@example.com")
                            infoRow(icon: "link", label: "Website", value: "yourportfolio.com")
                            infoRow(icon: "building.2.fill", label: "Company", value: "Independent Developer")
                        }
                        
                        sectionHeader("Technology Stack")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            techRow(name: "SwiftUI", description: "Modern declarative UI framework")
                            techRow(name: "Swift 5.9+", description: "Modern, safe, and fast")
                            techRow(name: "MVVM Architecture", description: "Clean separation of concerns")
                            techRow(name: "Async/Await", description: "Modern concurrency model")
                            techRow(name: "Combine", description: "Reactive programming")
                            techRow(name: "URLSession", description: "Native networking")
                        }
                        
                        sectionHeader("Features")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            featureRow("Application tracking with timeline")
                            featureRow("Automatic status management")
                            featureRow("Follow-up recommendations")
                            featureRow("Quick actions for common tasks")
                            featureRow("Native macOS design")
                            featureRow("Light & dark mode support")
                        }
                        
                        sectionHeader("Open Source")
                        
                        Text("This project demonstrates professional macOS development practices and modern Swift patterns. Built as a portfolio piece to showcase native app development skills.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        sectionHeader("Acknowledgments")
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("• Apple - SwiftUI, SF Symbols, HIG")
                            Text("• Google - Apps Script platform")
                            Text("• Swift Community - Best practices")
                        }
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 32)
                    
                    Divider()
                        .padding(.horizontal, 32)
                    
                    VStack(spacing: 12) {
                        Text("© 2026 Your Name. All rights reserved.")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            Link("GitHub", destination: URL(string: "https://github.com/yourusername")!)
                                .font(.system(size: 12, weight: .medium))
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Link("LinkedIn", destination: URL(string: "https://linkedin.com/in/yourprofile")!)
                                .font(.system(size: 12, weight: .medium))
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Link("Portfolio", destination: URL(string: "https://yourportfolio.com")!)
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            .padding(16)
        }
        .frame(width: 600, height: 700)
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.primary)
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    private func techRow(name: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.orange)
            
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    AboutView()
}
