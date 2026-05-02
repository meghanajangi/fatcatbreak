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
        statusMessage = selectedCount == 0
            ? "Select at least one app or website before starting."
            : "Selection saved."
    }

    func saveSettings() {
        sharedStore.usageLimitMinutes = usageLimitMinutes
        sharedStore.breakMinutes = breakMinutes
        statusMessage = "Settings saved."
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
        sharedStore.selection = selection
        saveSettings()
        scheduler.beginBreak()
        breakUntil = sharedStore.breakUntil
        statusMessage = "Previewing the cat break."
    }

    var selectedCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
    }
}
