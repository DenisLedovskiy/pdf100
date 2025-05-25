import UIKit

final class SettingSection: Section<PDF100CellModel> { }

extension SettingSection {

    static func makeSection() -> [SettingSection] {
        return [
            .init(title: "",
                  items: [PDF100CellModel(title: trans("Change icon"), icon: .sett0),
                          PDF100CellModel(title: trans("Share"), icon: .sett1),
                          PDF100CellModel(title: trans("Privacy policy"), icon: .sett2),
                          PDF100CellModel(title: trans("Terms of use"), icon: .sett3)])
        ]
    }
}
