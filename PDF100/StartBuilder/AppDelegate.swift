import UIKit
import SnapKit
import ApphudSDK
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var appDelegate: AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("not open appdelegate")
        }
        return appDelegate
    }
    
    var appBuilder = AppBuilder()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Task {
            Apphud.start(apiKey: Config.appHud.rawValue)
            MakeDollarService.shared.getProducts()

            let appHudmanager = MakeDollarService.shared
            let isActive = appHudmanager.isPremium

            _ = QuikManager.shared
            QuikManager.shared.updateQuickActions(hasActiveSubscription: isActive)

            if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
                QuikManager.shared.handle(shortcutItem)
            }
        }

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in }
        application.registerForRemoteNotifications()

        FirebaseApp.configure()

        appBuilder.start()
        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = QuikManager.shared.handle(shortcutItem)
        completionHandler(handled)
    }
}

//MARK: - Local Push
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Apphud.submitPushNotificationsToken(token: deviceToken, callback: nil)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        dump(error)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Apphud.handlePushNotification(apsInfo: response.notification.request.content.userInfo)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Apphud.handlePushNotification(apsInfo: notification.request.content.userInfo)
        completionHandler([])
    }
}
