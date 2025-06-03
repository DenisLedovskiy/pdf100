import UIKit

final class AppBuilder {

    private var window: UIWindow?

    func start() {
        if UserDefSettings.isNotOneEnter ?? false {
            startMainScene()
        } else {
            UserDefSettings.isShowedLikeIt = false
            UserDefSettings.isFirstIconSet = true
            UserDefSettings.isWasGoodMove = false
            goOnboardingScreen()
        }
    }

    func goOnboardingScreen() {
        let vc = OnbordingViewController()
        let navVC = UINavigationController(rootViewController: vc)
        showController(navVC)
    }

    func startMainScene() {
        let vc = makeTabBarController()
        showController(vc)
    }

    private func showController(_ controller: UIViewController) {
        let window = AppDelegate.appDelegate.window ?? UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = .light
        window.backgroundColor = .white
        AppDelegate.appDelegate.window = window

        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
}

extension AppBuilder {
    private func makeTabBarController() -> UITabBarController {
        let tabBarController = AppTabBar()
        tabBarController.viewControllers = [createVC(HomeInit.createViewController()),
                                            createVC(SettingsInit.createViewController())
        ]
        return tabBarController
    }

    func createVC(_ vc: UIViewController) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: vc)
        return navigationController
    }
}
