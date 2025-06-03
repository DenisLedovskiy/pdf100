import UIKit
import SafariServices

protocol PayWallBRouterInterface: AnyObject {
    func openLink(_ url: URL)
    func dismiss()
}

class PayWallBRouter: NSObject {
    weak var controller: UIViewController?
}

// MARK: - PayWallBRouterInterface

extension PayWallBRouter: PayWallBRouterInterface {
    func dismiss() {
        if UserDefSettings.isNotOneEnter ?? false {
            guard let viewController = controller else { return }
            viewController.dismiss(animated: false)
        } else {
            let appStarter = AppBuilder()
            appStarter.startMainScene()
        }
    }

    func openLink(_ url: URL) {
        guard let viewController = controller else { return }
        let safariVC = SFSafariViewController(url: url)
        viewController.present(safariVC, animated: true, completion: nil)
    }
}
