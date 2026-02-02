//
//  ContentView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright 2026 KaMy. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        Group {
            switch authManager.authState {
            case .splash:
                SplashView(authManager: authManager)
                    .transition(.opacity)
            case .login:
                LoginView(authManager: authManager)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            case .authenticated:
                MainContentView(authManager: authManager)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authManager.authState)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
