import UIKit

final class ImportSection: Section<PDF100CellModel> { }

extension ImportSection {

    static func makeSection() -> [ImportSection] {
        return [
            .init(title: "",
                  items: [PDF100CellModel(title: trans("Scan"), icon: .tabScan),
                          PDF100CellModel(title: trans("Gallery"), icon: .tabPhoto),
                          PDF100CellModel(title: trans("Files"), icon: .tabFiles)])
        ]
    }
}
