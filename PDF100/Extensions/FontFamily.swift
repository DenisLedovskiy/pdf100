import UIKit

enum FontFamily {
    case helix

    var prefix: String {
        switch self {
        case .helix:
            return "Hellix-"
        }
    }
}

private func customFont(_ type: UIFont.Weight = .regular,
                        size: CGFloat,
                        fontFamily: FontFamily) -> UIFont {
    var typeString = ""

    switch type {
    case .bold:
        typeString = "Bold"
    case .medium:
        typeString = "Medium"
    case .semibold:
        typeString = "SemiBold"
    case .regular:
        typeString = "Regular"
    case .thin:
        typeString = "Thin"
    case .heavy:
        typeString = "ExtraBold"
    case .black:
        typeString = "Black"
    default:
        return UIFont.systemFont(ofSize: size)
    }

    let fontName = fontFamily.prefix + typeString
    let font: UIFont = UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: type)
    return font
}

extension UIFont {

    static func hellix(_ type: UIFont.Weight, size: CGFloat) -> UIFont {
        return customFont(type, size: size, fontFamily: .helix)
    }
}
