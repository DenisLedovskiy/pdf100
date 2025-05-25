import UIKit

final class ImportCell: PDF100CollectionCell {

    // MARK: - properties

    private let cornerRadius: CGFloat = 15
    private let iconSize: CGFloat = 44

    // MARK: - views

    private lazy var cellIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .white
        return imageView
    }()

    private lazy var cellTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .hellix(.bold, size: 18)
        label.textColor = .textBlack
        return label
    }()

    // MARK: - overrides

    override class var size: CGSize {
        let width: CGFloat = (deviceWidth - 64 - 30)/3
        let height: CGFloat = 98
        return CGSize(
            width: width,
            height: height
        )
    }

    override func setup() {
        super.setup()

        backgroundColor = .white
        layer.cornerRadius = cornerRadius

        layer.shadowRadius = 10
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        clipsToBounds = false

        // MARK: - Add Subviews
        addSubview(cellIcon)
        addSubview(cellTitle)

        // MARK: - Add Constraints
        setupConstraints()
    }

    // MARK: - methods

    func configureCellData(_ data: PDF100CellModel) {
        cellTitle.text = data.title
        cellIcon.image = data.icon
    }
}

// MARK: - sizes extensions

extension ImportCell {

    func setupConstraints() {

        cellIcon.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(13)
            $0.size.equalTo(iconSize)
        })

        cellTitle.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.equalTo(cellIcon.snp.bottom).offset(8)
        })
    }
}
