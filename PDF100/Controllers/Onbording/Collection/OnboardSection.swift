import UIKit

final class OnboardSection: Section<OnboardCellModel> { }

extension OnboardSection {

    static func makeFirstSection() -> [OnboardSection] {
        return [
            .init(title: "",
                  items: [OnboardCellModel(title: trans("Legal advisor"), icon: .on10),
                          OnboardCellModel(title: trans("Office work"), icon: .on11),
                          OnboardCellModel(title: trans("Student"), icon: .on12),
                          OnboardCellModel(title: trans("IT professional"), icon: .on13),
                          OnboardCellModel(title: trans("Freelancer"), icon: .on14),
                          OnboardCellModel(title: trans("Other"), icon: .on15)])
        ]
    }

    static func makeSecondSection() -> [OnboardSection] {
        return [
            .init(title: "",
                  items: [OnboardCellModel(title: trans("Read PDF"), icon: .on20),
                          OnboardCellModel(title: trans("Edit PDF"), icon: .on21),
                          OnboardCellModel(title: trans("Sort pages"), icon: .on22),
                          OnboardCellModel(title: trans("Compress file"), icon: .on23),
                          OnboardCellModel(title: trans("Signature"), icon: .on24),
                          OnboardCellModel(title: trans("Convert"), icon: .on25)])
        ]
    }
}

