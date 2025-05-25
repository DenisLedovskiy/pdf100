import Foundation
import UIKit

struct ReorderCellModel {
    let id = UUID()
    var icon: UIImage
    var isSelect: Bool
}

extension ReorderCellModel: Hashable {
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: ReorderCellModel, rhs: ReorderCellModel) -> Bool {
      lhs.id == rhs.id
    }
}
