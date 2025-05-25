import UIKit

class PDF100CollectionCell: UICollectionViewCell {

    static var id: String {
        return String(describing: self)
    }

    class var size: CGSize {
        return CGSize(width: 0, height: 0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        //object configuration:
    }

    static func register(_ collectionView: UICollectionView) {
        collectionView.register(Self.self, forCellWithReuseIdentifier: Self.id)
    }

    static func getCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> Self {
        return collectionView.dequeueReusableCell(withReuseIdentifier: Self.id, for: indexPath) as! Self
    }
}
