//
//  LoginView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = true
    @State private var isAnimating = false
    @State private var showError = false

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                loginCard

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
            loadSavedCredentials()
        }
        .onChange(of: authManager.errorMessage) { oldValue, newValue in
            handleErrorChange(newValue)
        }
    }

    private var loginCard: some View {
        VStack(spacing: 28) {
            appIcon

            Text("Login to Trackra")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)

            formFields

            actionButtons
        }
        .frame(maxWidth: 380)
        .padding(.vertical, 40)
        .padding(.horizontal, 36)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.15), radius: 25, x: 0, y: 8)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .opacity(isAnimating ? 1.0 : 0.0)
        .offset(y: showError ? -5 : 0)
    }

    private var appIcon: some View {
        Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
            .resizable()
            .frame(width: 72, height: 72)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    private var formFields: some View {
        VStack(spacing: 14) {
            emailField
            passwordField
            errorMessageView
            rememberMeToggle
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email Address")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            TextField("your.email@example.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14))
                .textContentType(.emailAddress)
                .disableAutocorrection(true)
                .frame(height: 28)
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Password")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            SecureField("Enter your password", text: $password)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14))
                .textContentType(.password)
                .frame(height: 28)
        }
    }

    @ViewBuilder
    private var errorMessageView: some View {
        if let errorMessage = authManager.errorMessage {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 14))

                Text(errorMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.red)

                Spacer()
            }
            .padding(.horizontal, 4)
            .transition(.opacity)
        }
    }

    private var rememberMeToggle: some View {
        HStack {
            Toggle(isOn: $rememberMe) {
                Text("Remember me")
                    .font(.system(size: 13))
            }
            .toggleStyle(.checkbox)
            Spacer()
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            loginButton
            requestAccessButton
        }
    }

    private var loginButton: some View {
        Button(action: handleLogin) {
            HStack {
                if authManager.isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Sign In")
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
        .buttonStyle(.borderedProminent)
        .tint(Color(hex: "4F46E5"))
        .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
    }

    private var requestAccessButton: some View {
        Button(action: {
            EmailService.shared.sendAccessRequest(email: email)
        }) {
            Text("Request access")
                .font(.system(size: 12))
        }
        .buttonStyle(.link)
    }

    private func handleErrorChange(_ newValue: String?) {
        if newValue != nil {
            withAnimation(.default) {
                showError = true
            }

            withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                showError = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                    showError = false
                }
            }
        }
    }

    private func handleLogin() {
        Task {
            await authManager.login(email: email, password: password, rememberMe: rememberMe)
        }
    }

    private func loadSavedCredentials() {
        if let savedEmail = authManager.getSavedEmail() {
            email = savedEmail
            rememberMe = true
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LoginView(authManager: AuthenticationManager())
}
