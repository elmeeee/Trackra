//
//  SplashView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct SplashView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .frame(width: 96, height: 96)
                    .cornerRadius(22)
                    .shadow(color: Color.black.opacity(0.25), radius: 15, x: 0, y: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.85)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                VStack(spacing: 12) {
                    Text("Trackra")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Your personal career companion")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                
                ProgressView()
                    .controlSize(.regular)
                    .padding(.top, 8)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                isAnimating = true
            }
            
            Task {
                await authManager.performHealthCheck()
            }
        }
    }
}

#Preview {
    SplashView(authManager: AuthenticationManager())
}
