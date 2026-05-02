import DeviceActivity
import Foundation

enum CatConstants {
    static let appGroupIdentifier = "group.com.example.FatCatBreak"
    static let managedSettingsStoreName = "FatCatBreakStore"

    static let monitoredActivity = DeviceActivityName("fat-cat.social-monitor")
    static let breakActivity = DeviceActivityName("fat-cat.break-window")
    static let socialLimitEvent = DeviceActivityEvent.Name("fat-cat.social-limit")

    static let defaultUsageLimitMinutes = 30
    static let defaultBreakMinutes = 1

    static let suggestedApps = [
        "Instagram",
        "Reddit",
        "LinkedIn",
        "YouTube",
        "Facebook",
        "TikTok"
    ]
}
