import UIKit

final class PayWallInit {
    static func createViewController() -> UIViewController {
        let router = PayWallBRouter()
        let presenter = PayWallBPresenter(router: router)
        let viewController = PayWallViewController(presenter: presenter, router: router)

        router.controller = viewController

        return viewController
    }
}
