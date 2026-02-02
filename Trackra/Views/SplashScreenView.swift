//
//  SplashScreenView.swift
//  Trackra
//
//  Created by Elmee on 02/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                VStack(spacing: 8) {
                    Text("Trackra")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Loading your applications...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                ProgressView()
                    .controlSize(.regular)
                    .padding(.top, 8)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
