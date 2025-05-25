import UIKit

protocol SettingsPresenterInterface {
    func viewDidLoad(withView view: SettingsPresenterOutputInterface)
    func needShowPayWall()
    func selectShare()
    func selectTerm()
    func selectPrivacy()
    func selectIcon(sheet: UIViewController)
}

final class SettingsPresenter: NSObject {

    private weak var view: SettingsPresenterOutputInterface?
    private var router: SettingsRouterInterface

    init(router: SettingsRouterInterface) {
        self.router = router
    }
}

// MARK: - SettingsPresenterInterface

extension SettingsPresenter: SettingsPresenterInterface {
    func selectShare() {
        guard let url = URL(string: "https://apps.apple.com/us/app/id\(Config.appID.rawValue)") else {return}
        router.openShare(url)
    }
    
    func selectTerm() {
        guard let url = URL(string: Config.term.rawValue) else {
            return
          }
          router.openLink(url)
    }
    
    func selectPrivacy() {
        guard let url = URL(string: Config.privacy.rawValue) else {
            return
        }
        router.openLink(url)
    }
    
    func selectIcon(sheet: UIViewController) {
        router.openIconVC(sheet: sheet)
    }
    
    func needShowPayWall() {
        router.showPayWall()
    }
    
    func viewDidLoad(withView view: SettingsPresenterOutputInterface) {
        self.view = view
    }
}
