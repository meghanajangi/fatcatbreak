# Fat Cat Break

An iOS Screen Time app that monitors selected social apps and starts a cat break after the usage limit is reached.

## What It Does

- Requests Family Controls authorization.
- Lets the user choose Instagram, Reddit, LinkedIn, YouTube, Facebook, TikTok, or related websites through Apple's private Screen Time picker.
- Lets the user set a usage limit, defaulting to 30 minutes.
- Lets the user set a break time, defaulting to 1 minute.
- Shields the selected apps/websites when the threshold is reached.
- Shows a full-screen animated fat cat break inside the app.
- Customizes the iOS shield with cat-themed copy while the selected apps are blocked.

## Important iOS Limit

iOS apps cannot draw a Chrome-extension-style overlay on top of other apps. The approved Screen Time approach is to shield the overused apps. When the user tries to open a shielded app, iOS shows the shield UI supplied by the shield configuration extension.

## Setup

1. Open `FatCatBreak.xcodeproj` in Xcode.
2. Change every `com.example.FatCatBreak` bundle identifier to your own reverse-DNS identifier.
3. Change `group.com.example.FatCatBreak` in:
   - `Shared/CatConstants.swift`
   - `FatCatBreak/FatCatBreak.entitlements`
   - `CatBreakMonitorExtension/CatBreakMonitorExtension.entitlements`
   - `CatShieldConfigurationExtension/CatShieldConfigurationExtension.entitlements`
4. Enable the Family Controls capability for the app and both extensions.
5. Enable the shared App Group for the app and both extensions.
6. Run on a physical iPhone. Screen Time APIs do not behave like a normal UI-only app in previews or on all simulator configurations.

## Targets

- `FatCatBreak`: SwiftUI app and cat break UI.
- `CatBreakMonitorExtension`: Device Activity monitor that receives threshold callbacks.
- `CatShieldConfigurationExtension`: Managed Settings UI shield appearance.
