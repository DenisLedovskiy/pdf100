import Foundation

final class UserDefSettings {

    private enum UserDefSettingsKeys: String {
        case isNotOneEnter
        case isWasGoodMove
        case isShowedLikeIt
        case isFirstIconSet
    }

    static var isNotOneEnter: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: UserDefSettingsKeys.isNotOneEnter.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key = UserDefSettingsKeys.isNotOneEnter.rawValue
            if let flag = newValue {
                defaults.set(flag, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }

    static var isWasGoodMove: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: UserDefSettingsKeys.isWasGoodMove.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key = UserDefSettingsKeys.isWasGoodMove.rawValue
            if let flag = newValue {
                defaults.set(flag, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }

    static var isShowedLikeIt: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: UserDefSettingsKeys.isShowedLikeIt.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key = UserDefSettingsKeys.isShowedLikeIt.rawValue
            if let flag = newValue {
                defaults.set(flag, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }

    static var isFirstIconSet: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: UserDefSettingsKeys.isFirstIconSet.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key = UserDefSettingsKeys.isFirstIconSet.rawValue
            if let flag = newValue {
                defaults.set(flag, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
}
