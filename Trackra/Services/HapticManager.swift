//
//  HapticManager.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import SwiftUI

#if os(iOS)
    import UIKit
#endif

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    enum NotificationType {
        case success, warning, error
    }

    enum ImpactStyle {
        case light, medium, heavy
    }

    func notification(type: NotificationType) {
        #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            let feedbackType: UINotificationFeedbackGenerator.FeedbackType
            switch type {
            case .success: feedbackType = .success
            case .warning: feedbackType = .warning
            case .error: feedbackType = .error
            }
            generator.notificationOccurred(feedbackType)
        #elseif os(macOS)
            let pattern: NSHapticFeedbackManager.FeedbackPattern
            switch type {
            case .success: pattern = .alignment
            case .warning, .error: pattern = .levelChange
            }
            NSHapticFeedbackManager.defaultPerformer.perform(pattern, performanceTime: .default)
        #endif
    }

    func impact(style: ImpactStyle) {
        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)  // Simplified mapping
            generator.impactOccurred()
        #elseif os(macOS)
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
        #endif
    }

    func selection() {
        #if os(iOS)
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        #elseif os(macOS)
            // Generic subtle feedback for macOS
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
        #endif
    }
}
