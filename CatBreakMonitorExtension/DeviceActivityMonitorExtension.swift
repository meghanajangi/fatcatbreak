import DeviceActivity
import Foundation

final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let scheduler = ScreenTimeScheduler()

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        guard activity == CatConstants.monitoredActivity,
              event == CatConstants.socialLimitEvent else { return }

        do {
            try scheduler.beginBreak()
        } catch {
            scheduler.clearShield()
            SharedActivityStore().clearBreak()
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        if activity == CatConstants.breakActivity {
            scheduler.clearShield()
            let sharedStore = SharedActivityStore()
            sharedStore.clearBreak()
            try? scheduler.startMonitoring(selection: sharedStore.selection)
        }
    }
}
