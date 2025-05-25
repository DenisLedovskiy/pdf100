import UIKit

final class HomeSection: Section<HomeCellModel> { }

extension HomeSection {

    static func makeSection(_ data: [HomeCellModel]) -> [HomeSection] {
        return [
            .init(title: "",
                  items: data)
        ]
    }
}
