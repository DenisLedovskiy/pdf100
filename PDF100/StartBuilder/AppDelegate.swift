import UIKit

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
        
        appBuilder.start()
        return true
    }
}

