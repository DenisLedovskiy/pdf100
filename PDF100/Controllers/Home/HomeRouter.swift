import UIKit

protocol HomeRouterInterface: AnyObject {
    func showFeedback()
    func showShare(_ url: URL)
    func showConvertMenu(sheet: UIViewController)
    func showDocument()
    func showCompress()
}

class HomeRouter: NSObject {
    weak var controller: UIViewController?
}

// MARK: - HomeRouterInterface

extension HomeRouter: HomeRouterInterface {
    func showCompress() {
        guard let viewController = controller else { return }
        let controller = Compress()
        viewController.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showDocument() {
        guard let viewController = controller else { return }
        let controller = PreviewInit.createViewController()
        viewController.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showConvertMenu(sheet: UIViewController) {
        guard let viewController = controller else { return }
        viewController.present(sheet, animated: true)
    }
    
    func showShare(_ url: URL) {
        guard let viewController = controller else { return }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    func showFeedback() {
        guard let viewController = controller else { return }
        let vc = Feedback()
        vc.modalPresentationStyle = .overFullScreen
        viewController.present(vc, animated: false)
    }
}
