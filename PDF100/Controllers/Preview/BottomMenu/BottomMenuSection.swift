import UIKit

final class BottomMenuSection: Section<PDF100CellModel> { }

extension BottomMenuSection {

    static func makePreviewSection() -> [BottomMenuSection] {
        return [
            .init(title: "",
                  items: [PDF100CellModel(title: trans("reader"), icon: .btReaderOff, isSelect: false),
                          PDF100CellModel(title: trans("reorder"), icon: .btReorder),
                          PDF100CellModel(title: trans("edit"), icon: .btEdit),
                          PDF100CellModel(title: trans("add pages"), icon: .btAddOff, isSelect: false)])
        ]
    }

    static func makeSelectPreviewSection() -> [BottomMenuSection] {
        return [
            .init(title: "",
                  items: [PDF100CellModel(title: trans("reader"), icon: .btReaderOn, isSelect: true),
                          PDF100CellModel(title: trans("reorder"), icon: .btReorder),
                          PDF100CellModel(title: trans("edit"), icon: .btEdit),
                          PDF100CellModel(title: trans("add pages"), icon: .btAddOff, isSelect: false)])
        ]
    }

    static func makeSelectAddSection() -> [BottomMenuSection] {
        return [
            .init(title: "",
                  items: [PDF100CellModel(title: trans("reader"), icon: .btReaderOff, isSelect: false),
                          PDF100CellModel(title: trans("reorder"), icon: .btReorder),
                          PDF100CellModel(title: trans("edit"), icon: .btEdit),
                          PDF100CellModel(title: trans("add pages"), icon: .btAddOn, isSelect: true)])
        ]
    }

    static func makeEditSection() -> [BottomMenuSection] {
        return [
            .init(title: "",
                  items: [PDF100CellModel(title: trans("rotate"), icon: .rotateOff, isSelect: false),
                          PDF100CellModel(title: trans("Delete").lowercased(), icon: .deleteOff, isSelect: false)])
        ]
    }

    static func makeEditOnSection() -> [BottomMenuSection] {
        return [
            .init(title: "",
                  items: [PDF100CellModel(title: trans("rotate"), icon: .rotateOn, isSelect: true),
                          PDF100CellModel(title: trans("Delete").lowercased(), icon: .deleteOn, isSelect: true)])
        ]
    }

}
