import UIKit

final class PreviewInit {
    static func createViewController(docName: String) -> UIViewController {
        let router = PreviewRouter()
        let presenter = PreviewPresenter(router: router)
        let viewController = PreviewViewController(docName: docName,
                                                   presenter: presenter,
                                                   router: router)

        router.controller = viewController

        return viewController
    }
}
