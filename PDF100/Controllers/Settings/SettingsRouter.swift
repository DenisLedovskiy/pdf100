import UIKit
import SafariServices

protocol SettingsRouterInterface: AnyObject {
    func showPayWall()
    func openLink(_ url: URL)
    func openShare(_ url: URL)
    func openIconVC(sheet: UIViewController)
}

class SettingsRouter: NSObject {
    weak var controller: UIViewController?
}

// MARK: - SettingsRouterInterface

extension SettingsRouter: SettingsRouterInterface {
    func openIconVC(sheet: UIViewController) {
        guard let viewController = controller else { return }
        viewController.present(sheet, animated: true)
    }

    func openShare(_ url: URL) {
        guard let viewController = controller else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        viewController.present(vc, animated: true)
    }

    func openLink(_ url: URL) {
        guard let viewController = controller else { return }
        let safariVC = SFSafariViewController(url: url)
        viewController.present(safariVC, animated: true, completion: nil)
    }

    func showPayWall() {
        guard let viewController = controller else { return }
        let vc = PayWallInit.createViewController()
        vc.modalPresentationStyle = .overFullScreen
        viewController.present(vc, animated: true)
    }
}
