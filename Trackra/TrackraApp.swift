//
//  TrackraApp.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//

import SwiftUI

@main
struct TrackraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Trackra") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "A modern career companion for macOS",
                                attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
                            ),
                            NSApplication.AboutPanelOptionKey.applicationVersion: "1.0",
                            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© 2026 KaMy"
                        ]
                    )
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        for window in NSApplication.shared.windows {
                            if window.title == "About Trackra" {
                                window.close()
                            }
                        }
                        openAboutWindow()
                    }
                }
            }
            
            CommandGroup(replacing: .newItem) {
                Button("New Application") {
                    NotificationCenter.default.post(name: .addApplication, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        
        Window("About Trackra", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
    
    private func openAboutWindow() {
        let aboutWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 700),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        aboutWindow.title = "About Trackra"
        aboutWindow.contentView = NSHostingView(rootView: AboutView())
        aboutWindow.center()
        aboutWindow.makeKeyAndOrderFront(nil)
        aboutWindow.isReleasedWhenClosed = false
    }
}

extension Notification.Name {
    static let addApplication = Notification.Name("addApplication")
}
