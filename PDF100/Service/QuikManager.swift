import UIKit

class QuikManager {
    static let shared = QuikManager()

    enum Action: String, CaseIterable {
        case openSubscription = ".opensubscription"

        var fullType: String {
            return (Bundle.main.bundleIdentifier ?? "") + self.rawValue
        }
    }

    var quickAction: Action? = nil
    private var hasActiveSubscription = true {
        didSet {
            updateQuickActions(hasActiveSubscription: hasActiveSubscription)
        }
    }

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(subscriptionStatusChanged(_:)),
            name: .didChangeSubscriptionStatus,
            object: nil
        )
    }

    @objc private func subscriptionStatusChanged(_ notification: Notification) {
        if let isActive = notification.userInfo?["isActive"] as? Bool {
            hasActiveSubscription = isActive
        }
    }

    func handle(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let action = Action.allCases.first(where: { $0.fullType == shortcutItem.type }) else {
            return false
        }
        quickAction = action
        NotificationCenter.default.post(
            name: .didReceiveQuickAction,
            object: action
        )
        return true
    }

    func updateQuickActions(hasActiveSubscription: Bool) {
        if hasActiveSubscription {
            UIApplication.shared.shortcutItems = []
        } else {
            let subType = Action.openSubscription.fullType
            let subscriptionAction = UIApplicationShortcutItem(
                type: subType,
                localizedTitle: trans("🔥 Don't delete!"),
                localizedSubtitle: trans("Try it at 40% off!"),
                icon: UIApplicationShortcutIcon(type: .prohibit),
                userInfo: nil
            )
            UIApplication.shared.shortcutItems = [subscriptionAction]
        }
    }

    func configureQuickActions() {
        updateQuickActions(hasActiveSubscription: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension Notification.Name {
    static let didChangeSubscriptionStatus = Notification.Name("didChangeSubscriptionStatus")
    static let didReceiveQuickAction    = Notification.Name("didReceiveQuickAction")
}
