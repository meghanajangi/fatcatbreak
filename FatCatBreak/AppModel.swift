import FamilyControls
import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published var selection: FamilyActivitySelection
    @Published var isMonitoring = false
    @Published var breakUntil: Date?
    @Published var statusMessage = "Pick the social apps once, then let the cat enforce the break."
    @Published var usageLimitMinutes: Int
    @Published var breakMinutes: Int

    private let scheduler = ScreenTimeScheduler()
    private let sharedStore = SharedActivityStore()

    init() {
        selection = sharedStore.selection
        breakUntil = sharedStore.breakUntil
        usageLimitMinutes = sharedStore.usageLimitMinutes
        breakMinutes = sharedStore.breakMinutes
    }

    func refreshBreakState() {
        guard sharedStore.breakUntil != nil else {
            breakUntil = nil
            return
        }

        scheduler.endBreakIfExpired()
        breakUntil = sharedStore.breakUntil
    }

    func requestAuthorization() async {
        guard AuthorizationCenter.shared.authorizationStatus != .approved else {
            statusMessage = "Screen Time access is ready."
            return
        }

        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            statusMessage = "Screen Time access is ready."
        } catch {
            statusMessage = "Screen Time permission was not granted: \(error.localizedDescription)"
        }
    }

    func saveSelection() {
        sharedStore.selection = selection

        guard selectedCount > 0 else {
            if isMonitoring {
                scheduler.stopMonitoring()
                isMonitoring = false
            }
            statusMessage = "Select at least one app or website before starting."
            return
        }

        guard isMonitoring else {
            statusMessage = "Selection saved."
            return
        }

        do {
            try scheduler.startMonitoring(selection: selection)
            statusMessage = "Selection saved and monitoring restarted."
        } catch {
            isMonitoring = false
            statusMessage = "Selection saved, but monitoring could not restart: \(error.localizedDescription)"
        }
    }

    func saveSettings() {
        sharedStore.usageLimitMinutes = usageLimitMinutes
        sharedStore.breakMinutes = breakMinutes

        guard isMonitoring else {
            statusMessage = "Settings saved."
            return
        }

        do {
            try scheduler.startMonitoring(selection: selection)
            statusMessage = "Settings saved and monitoring restarted."
        } catch {
            isMonitoring = false
            statusMessage = "Settings saved, but monitoring could not restart: \(error.localizedDescription)"
        }
    }

    func startMonitoring() {
        guard selectedCount > 0 else {
            statusMessage = "Select the apps first, then start monitoring."
            return
        }

        do {
            try scheduler.startMonitoring(selection: selection)
            isMonitoring = true
            statusMessage = "Monitoring started. The cat steps in after \(usageLimitMinutes) minutes."
        } catch {
            statusMessage = "Could not start monitoring: \(error.localizedDescription)"
        }
    }

    func stopMonitoring() {
        scheduler.stopMonitoring()
        isMonitoring = false
        breakUntil = nil
        statusMessage = "Monitoring stopped."
    }

    func previewBreak() {
        sharedStore.usageLimitMinutes = usageLimitMinutes
        sharedStore.breakMinutes = breakMinutes
        breakUntil = Date().addingTimeInterval(TimeInterval(breakMinutes * 60))
        statusMessage = "Previewing the cat break. Screen Time shielding is not active in preview."
    }

    var selectedCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
    }
}
