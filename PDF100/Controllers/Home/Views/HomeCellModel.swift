import Foundation
import UIKit

struct HomeCellModel {
    let id = UUID()
    let idCD: UUID
    var title: String
    var icon: UIImage
    var size: String
    var date: Date
}

extension HomeCellModel: Hashable {
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: HomeCellModel, rhs: HomeCellModel) -> Bool {
      lhs.id == rhs.id
    }
}
