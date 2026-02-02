//
//  TrackraApp.swift
//  Trackra
//
//  Created by Elmee on 01/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
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
                    let credits = NSMutableAttributedString()
                    
                    // Paragraph style for better spacing
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 4
                    paragraphStyle.alignment = .left
                    
                    // Description
                    let description = NSAttributedString(
                        string: "A modern career companion for macOS\n\n",
                        attributes: [
                            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11),
                            NSAttributedString.Key.foregroundColor: NSColor.secondaryLabelColor,
                            NSAttributedString.Key.paragraphStyle: paragraphStyle
                        ]
                    )
                    credits.append(description)
                    
                    // Developer section header
                    let developerHeader = NSAttributedString(
                        string: "DEVELOPER\n",
                        attributes: [
                            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9, weight: .semibold),
                            NSAttributedString.Key.foregroundColor: NSColor.tertiaryLabelColor,
                            NSAttributedString.Key.paragraphStyle: paragraphStyle
                        ]
                    )
                    credits.append(developerHeader)
                    
                    // Website
                    let websiteIcon = NSAttributedString(
                        string: "🌐  ",
                        attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
                    )
                    credits.append(websiteIcon)
                    
                    let website = NSAttributedString(
                        string: "elmee.web.app\n",
                        attributes: [
                            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11),
                            NSAttributedString.Key.foregroundColor: NSColor.linkColor,
                            NSAttributedString.Key.link: "https://elmee.web.app",
                            NSAttributedString.Key.underlineStyle: 0
                        ]
                    )
                    credits.append(website)
                    
                    // GitHub
                    let githubIcon = NSAttributedString(
                        string: "💻  ",
                        attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
                    )
                    credits.append(githubIcon)
                    
                    let github = NSAttributedString(
                        string: "github.com/elmeeee\n",
                        attributes: [
                            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11),
                            NSAttributedString.Key.foregroundColor: NSColor.linkColor,
                            NSAttributedString.Key.link: "https://github.com/elmeeee",
                            NSAttributedString.Key.underlineStyle: 0
                        ]
                    )
                    credits.append(github)
                    
                    // LinkedIn
                    let linkedinIcon = NSAttributedString(
                        string: "💼  ",
                        attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
                    )
                    credits.append(linkedinIcon)
                    
                    let linkedin = NSAttributedString(
                        string: "linkedin.com/in/elmysf\n",
                        attributes: [
                            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11),
                            NSAttributedString.Key.foregroundColor: NSColor.linkColor,
                            NSAttributedString.Key.link: "https://www.linkedin.com/in/elmysf/",
                            NSAttributedString.Key.underlineStyle: 0
                        ]
                    )
                    credits.append(linkedin)
                    
                    // Email
                    let emailIcon = NSAttributedString(
                        string: "📧  ",
                        attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
                    )
                    credits.append(emailIcon)
                    
                    let email = NSAttributedString(
                        string: "elmysf@yahoo.com",
                        attributes: [
                            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11),
                            NSAttributedString.Key.foregroundColor: NSColor.linkColor,
                            NSAttributedString.Key.link: "mailto:elmysf@yahoo.com",
                            NSAttributedString.Key.underlineStyle: 0
                        ]
                    )
                    credits.append(email)
                    
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: credits,
                            NSApplication.AboutPanelOptionKey.applicationVersion: "1.0",
                            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© 2026 KaMy"
                        ]
                    )
                }
            }
            
            CommandGroup(replacing: .newItem) {
                Button("New Application") {
                    NotificationCenter.default.post(name: .addApplication, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}

extension Notification.Name {
    static let addApplication = Notification.Name("addApplication")
}
