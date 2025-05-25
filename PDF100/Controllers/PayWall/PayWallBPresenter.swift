import UIKit

protocol PayWallBPresenterInterface {
    func viewDidLoad(withView view: PayWallBPresenterOutputInterface)
    func selectPP()
    func selectTerm()
    func selectClose()
}

final class PayWallBPresenter: NSObject {

    private weak var view: PayWallBPresenterOutputInterface?
    private var router: PayWallBRouterInterface

    init(router: PayWallBRouterInterface) {
        self.router = router
    }
}

// MARK: - PayWallBPresenterInterface

extension PayWallBPresenter: PayWallBPresenterInterface {

    func selectClose() {
        DispatchQueue.main.async {
            self.router.dismiss()
        }
    }

    func viewDidLoad(withView view: PayWallBPresenterOutputInterface) {
        self.view = view
    }

    func selectPP() {
        guard let url = URL(string: Config.privacy.rawValue) else {
            return
        }
        router.openLink(url)
    }

    func selectTerm() {
        guard let url = URL(string: Config.term.rawValue) else {
          return
        }
        router.openLink(url)
    }
}
