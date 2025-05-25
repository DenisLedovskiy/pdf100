import UIKit

final class ReorderSection: Section<ReorderCellModel> { }

extension ReorderSection {

    static func makeSection(_ images: [UIImage]) -> [ReorderSection] {
        let items = images.map({
            ReorderCellModel(icon: $0,
                             isSelect: false)
        })
        return [
            .init(title: "",
                  items: items)
        ]
    }
}
