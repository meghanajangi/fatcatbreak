import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

struct ScreenTimeScheduler {
    private let center = DeviceActivityCenter()
    private let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(CatConstants.managedSettingsStoreName))
    private let sharedStore = SharedActivityStore()

    func startMonitoring(selection: FamilyActivitySelection) throws {
        guard selection.hasSelectedItems else { return }

        sharedStore.selection = selection

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: sharedStore.usageLimitMinutes)
        )

        try center.startMonitoring(
            CatConstants.monitoredActivity,
            during: schedule,
            events: [CatConstants.socialLimitEvent: event]
        )
    }

    func stopMonitoring() {
        center.stopMonitoring([CatConstants.monitoredActivity, CatConstants.breakActivity])
        clearShield()
        sharedStore.clearBreak()
    }

    func beginBreak() throws {
        let until = Date().addingTimeInterval(TimeInterval(sharedStore.breakMinutes * 60))
        try scheduleBreakWindow(endingAt: until)
        sharedStore.breakUntil = until
        applyShield()
    }

    func endBreakIfExpired(now: Date = Date()) {
        guard let until = sharedStore.breakUntil else { return }
        if now >= until {
            clearShield()
            sharedStore.clearBreak()
            center.stopMonitoring([CatConstants.breakActivity])
            try? startMonitoring(selection: sharedStore.selection)
        }
    }

    func clearShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    private func applyShield() {
        let selection = sharedStore.selection
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens

        if selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = nil
        } else {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
    }

    private func scheduleBreakWindow(endingAt endDate: Date) throws {
        let calendar = Calendar.current
        let start = calendar.dateComponents([.hour, .minute, .second], from: Date())
        let end = calendar.dateComponents([.hour, .minute, .second], from: endDate)
        let schedule = DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: false)

        try center.startMonitoring(CatConstants.breakActivity, during: schedule)
    }
}

private extension FamilyActivitySelection {
    var hasSelectedItems: Bool {
        !applicationTokens.isEmpty || !categoryTokens.isEmpty || !webDomainTokens.isEmpty
    }
}
