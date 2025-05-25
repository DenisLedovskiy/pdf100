import Foundation
import UIKit

struct PDF100CellModel {
    let id = UUID()
    var title: String
    var icon: UIImage
    var isSelect: Bool = false
}

extension PDF100CellModel: Hashable {
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: PDF100CellModel, rhs: PDF100CellModel) -> Bool {
      lhs.id == rhs.id
    }
}
