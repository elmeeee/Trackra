//
//  SkeletonLoadingView.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

struct SkeletonLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { _ in
                    skeletonRow
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
        }
        .opacity(isAnimating ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
    
    private var skeletonRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    // Role title
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 180, height: 15)
                    
                    // Company name
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 120, height: 13)
                }
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                // Status badge placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 22)
                
                Spacer()
                
                // Time indicator placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 90, height: 12)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
