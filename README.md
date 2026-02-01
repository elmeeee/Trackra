# Trackra – Career Companion for macOS

A native macOS application for tracking job applications and their lifecycle, built with SwiftUI.

## Overview

Trackra is a career companion that helps you:
- Track job applications and their current status
- Visualize your hiring journey timeline
- Detect when follow-ups are needed
- Reduce cognitive load when managing multiple applications

## Features

### Core Functionality
- **Application Management**: Track role, company, application date, location, salary range, and more
- **Activity Timeline**: Visualize the complete history of each application
- **Status Tracking**: Automatic status updates based on activities (Applied, Interview, Offering, Rejected, No Response)
- **Quick Actions**: Fast access to common activities like scheduling interviews, adding follow-ups, or recording rejections
- **Follow-Up Alerts**: Visual indicators when applications haven't received responses for 14+ days

### User Experience
- Native macOS design with sidebar + detail layout
- Full keyboard navigation support
- Light and dark mode support
- Loading, error, and empty states
- Fast and responsive async/await networking

## Technical Stack

- **Platform**: macOS 14+
- **Framework**: SwiftUI only (no UIKit, no Catalyst)
- **Architecture**: MVVM with centralized app state
- **Networking**: URLSession with async/await
- **Backend**: Google Apps Script + Google Sheets

## Status Model

The application status is **backend-driven only**. The client never computes or modifies status values.

### Status Values
- `applied` - Initial application submitted
- `interview` - Interview scheduled or completed
- `offering` - Offer received
- `rejected` - Application rejected
- `no_response` - No activity for 14+ days

### Activity Types
- `interview_scheduled` - Interview scheduled
- `interview_done` - Interview completed
- `offer_received` - Offer received
- `rejected` - Application rejected
- `note` - General note
- `follow_up` - Follow-up sent

## Building and Running

### Requirements
- macOS 26.0 or later
- Xcode 26.0 or later
- Swift 6.0 or later

### Steps
1. Open `Trackra.xcodeproj` in Xcode
2. Select the Trackra scheme
3. Build and run (⌘R)

## Keyboard Shortcuts

- `⌘N` - Add new application
- `⌘R` - Refresh applications list
- Arrow keys - Navigate application list
- Return - Select application

## Architecture Decisions

### MVVM Pattern
- **Models**: Immutable domain models (Application, Activity)
- **ViewModels**: AppState manages all business logic and API calls
- **Views**: Pure SwiftUI views with no business logic

### Dependency Injection
The APIClient is injected into AppState, making it easy to test and swap implementations.

### Error Handling
- Network errors are caught and displayed to users
- Partial backend failures don't crash the app
- Loading states provide feedback during async operations

### Date Handling
ISO-8601 date format with fractional seconds support for backend compatibility.

## Design Principles

1. **Backend as Source of Truth**: Never compute status client-side
2. **Native macOS Experience**: Use platform conventions and components
3. **Keyboard-First**: Full keyboard navigation support
4. **Professional Quality**: Production-ready code, not a prototype
5. **Minimal and Focused**: Clean UI without distractions

## Non-Goals

- Authentication (not required by backend)
- Multi-user support
- Editing or overriding status values
- Editing or deleting activities
- Offline write-back

## Future Enhancements

Potential improvements for future versions:
- Export applications to CSV/PDF
- Advanced filtering and search
- Custom tags and categories
- Statistics and analytics dashboard
- Calendar integration
- Notification reminders

---

## License

Copyright © 2026. All rights reserved.

**Trackra** is a portfolio project demonstrating professional macOS development skills.
# Trackra
