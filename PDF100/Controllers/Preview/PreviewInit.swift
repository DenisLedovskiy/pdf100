import UIKit

final class PreviewInit {
    static func createViewController() -> UIViewController {
        let router = PreviewRouter()
        let presenter = PreviewPresenter(router: router)
        let viewController = PreviewViewController(presenter: presenter,
                                                                     router: router)

        router.controller = viewController

        return viewController
    }
}
