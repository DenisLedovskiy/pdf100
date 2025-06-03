import UIKit

protocol PreviewRouterInterface: AnyObject {
    func dismiss()
    func showDelete(sheet: UIViewController)
    func routeReorder(name: String)
}

class PreviewRouter: NSObject {
    weak var controller: UIViewController?
}

// MARK: - PreviewRouterInterface

extension PreviewRouter: PreviewRouterInterface {
    func routeReorder(name: String) {
        guard let viewController = controller else { return }
        let controller = ReorderVC(docName: name)
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
