import ManagedSettings
import ManagedSettingsUI
import UIKit

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        catShieldConfiguration
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        catShieldConfiguration
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        catShieldConfiguration
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        catShieldConfiguration
    }

    private var catShieldConfiguration: ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor(red: 1.0, green: 0.93, blue: 0.68, alpha: 1.0),
            icon: UIImage(systemName: "cat.fill"),
            title: ShieldConfiguration.Label(
                text: "The cat has taken over",
                color: .black
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Your scrolling limit is up. Rest until the break ends, then the timer starts fresh.",
                color: UIColor.black.withAlphaComponent(0.72)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Okay",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.05, green: 0.35, blue: 0.36, alpha: 1.0),
            secondaryButtonLabel: nil
        )
    }
}
