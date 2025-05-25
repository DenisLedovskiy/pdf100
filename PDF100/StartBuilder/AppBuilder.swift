import UIKit

final class AppBuilder {

    private var window: UIWindow?

    func start() {
        startMainScene()
//        goOnboardingScreen()
//        if UserSet.isNotFirstEnter ?? false {
//            startMainScene()
//        } else {
//            UserSet.isShowedLikeIt = false
//            UserSet.isFirstIconSet = true
//            UserSet.isWasSuccesMove = false
//            goOnboardingScreen()
//        }
    }

    func goOnboardingScreen() {
        let vc = PayWallInit.createViewController()
        showController(vc)

//        let vc = UINavigationController(rootViewController: OnbordingViewController())
//        showController(vc)
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
