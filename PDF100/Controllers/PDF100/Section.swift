import Foundation

class Section<T: Hashable>: Hashable {
    typealias item = T

    var id: UUID = UUID()
    var title: String
    var items: [item]

    init(title: String, items: [item]) {
        self.title = title
        self.items = items
    }
}

extension Section {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.id == rhs.id
    }
}
