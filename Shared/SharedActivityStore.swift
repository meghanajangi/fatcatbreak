import FamilyControls
import Foundation

struct SharedActivityStore {
    private enum Key {
        static let selection = "familyActivitySelection"
        static let breakUntil = "breakUntil"
        static let usageLimitMinutes = "usageLimitMinutes"
        static let breakMinutes = "breakMinutes"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = UserDefaults(suiteName: CatConstants.appGroupIdentifier) ?? .standard) {
        self.defaults = defaults
    }

    var selection: FamilyActivitySelection {
        get {
            guard let data = defaults.data(forKey: Key.selection),
                  let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) else {
                return FamilyActivitySelection()
            }

            return selection
        }
        nonmutating set {
            guard let data = try? PropertyListEncoder().encode(newValue) else { return }
            defaults.set(data, forKey: Key.selection)
        }
    }

    var breakUntil: Date? {
        get { defaults.object(forKey: Key.breakUntil) as? Date }
        nonmutating set { defaults.set(newValue, forKey: Key.breakUntil) }
    }

    var usageLimitMinutes: Int {
        get {
            let value = defaults.integer(forKey: Key.usageLimitMinutes)
            return value == 0 ? CatConstants.defaultUsageLimitMinutes : value
        }
        nonmutating set {
            defaults.set(max(1, newValue), forKey: Key.usageLimitMinutes)
        }
    }

    var breakMinutes: Int {
        get {
            let value = defaults.integer(forKey: Key.breakMinutes)
            return value == 0 ? CatConstants.defaultBreakMinutes : value
        }
        nonmutating set {
            defaults.set(max(1, newValue), forKey: Key.breakMinutes)
        }
    }

    func clearBreak() {
        defaults.removeObject(forKey: Key.breakUntil)
    }
}
