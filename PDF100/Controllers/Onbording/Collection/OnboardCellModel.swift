import Foundation
import UIKit

struct OnboardCellModel {
    let id = UUID()
    var title: String
    var icon: UIImage
}

extension OnboardCellModel: Hashable {
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: OnboardCellModel, rhs: OnboardCellModel) -> Bool {
      lhs.id == rhs.id
    }
}
