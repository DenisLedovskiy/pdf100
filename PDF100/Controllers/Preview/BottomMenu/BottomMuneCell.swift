import UIKit

final class BottomMuneCell: PDF100CollectionCell {

    // MARK: - properties

    private let iconSize: CGFloat = 24

    private let gradientColor: UIColor = UIColor(patternImage: .gradientSample)

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
        label.numberOfLines = 2
        label.font = .hellix(.semibold, size: 14)
        label.textColor = .subtitle
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    // MARK: - overrides

    override class var size: CGSize {
        let width: CGFloat = (deviceWidth - 40)/4
        let height: CGFloat = 62
        return CGSize(
            width: width,
            height: height
        )
    }

    override func setup() {
        super.setup()

        backgroundColor = .clear

        // MARK: - Add Subviews
        addSubview(cellIcon)
        addSubview(cellTitle)

        // MARK: - Add Constraints
        setupConstraints()
    }

    // MARK: - methods

    func configureCellData(_ data: PDF100CellModel) {
        cellTitle.text = data.title.lowercased()
        cellIcon.image = data.icon
        if data.isSelect {
            cellTitle.textColor = gradientColor
        } else {
            cellTitle.textColor = .subtitle
        }
    }
}

// MARK: - sizes extensions

extension BottomMuneCell {

    func setupConstraints() {

        cellIcon.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(3)
            if isSmallPhone {
                $0.height.equalTo(iconSize)
                $0.width.equalTo(22)
            } else {
                $0.size.equalTo(iconSize)
            }

        })

        cellTitle.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(2)
            $0.top.equalTo(cellIcon.snp.bottom).offset(1)
        })
    }
}
