import UIKit

final class SettingsInit {
    static func createViewController() -> UIViewController {
        let router = SettingsRouter()
        let presenter = SettingsPresenter(router: router)
        let viewController = SettingsViewController(presenter: presenter,
                                                                     router: router)

        router.controller = viewController

        return viewController
    }
}
