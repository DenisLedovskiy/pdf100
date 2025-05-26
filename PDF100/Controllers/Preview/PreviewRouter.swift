import UIKit

protocol PreviewRouterInterface: AnyObject {
    func dismiss()
    func showDelete(sheet: UIViewController)
    func routeReorder()
}

class PreviewRouter: NSObject {
    weak var controller: UIViewController?
}

// MARK: - PreviewRouterInterface

extension PreviewRouter: PreviewRouterInterface {
    func routeReorder() {
        guard let viewController = controller else { return }
        let controller = ReorderVC()
        viewController.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showDelete(sheet: UIViewController) {
        guard let viewController = controller else { return }
        viewController.present(sheet, animated: true)
    }
    
    func dismiss() {
        guard let viewController = controller else { return }
        viewController.navigationController?.popViewController(animated: true)
    }
}
