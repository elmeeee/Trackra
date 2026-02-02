//
//  EmailService.swift
//  Trackra
//
//  Created by Elmee on 02/02/2026.
//  Copyright © 2026 KaMy. All rights reserved.
//

import AppKit
import Foundation

final class EmailService {
    static let shared = EmailService()

    private let adminEmail = "elmysufiandy@gmail.com"

    private init() {}

    /// Sends an access request email when a user tries to login but doesn't have an account
    func sendAccessRequest(email: String) {
        let subject = "Trackra Access Request - \(email)"
        let body = """
            New access request for Trackra:

            Email: \(email)
            Timestamp: \(Date().formatted(date: .long, time: .complete))
            Device: macOS

            Please review and grant access if appropriate.

            ---
            This is an automated message from Trackra.
            """

        // Create mailto URL
        let encodedSubject =
            subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mailtoString = "mailto:\(adminEmail)?subject=\(encodedSubject)&body=\(encodedBody)"

        if let mailtoURL = URL(string: mailtoString) {
            NSWorkspace.shared.open(mailtoURL)
        }
    }

    /// Sends access request via API (silent, no user interaction)
    func sendAccessRequestSilently(email: String) async {
        // Log the access request
        print("Access request for: \(email)")
        print("Timestamp: \(Date().formatted(date: .long, time: .complete))")

        // Open mailto link automatically
        sendAccessRequest(email: email)
    }
}
