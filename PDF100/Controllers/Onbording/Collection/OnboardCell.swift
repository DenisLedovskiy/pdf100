import UIKit

final class OnboardCell: PDF100CollectionCell {
    private var imageTopInset: Double = switch phoneSize {
    case .small: 12
    case .medium: 18
    case .big: 24
    }

    // MARK: - properties

    private let cornerRadius: CGFloat = 20
    private let iconSize: CGFloat = 51

    // MARK: - views

    private lazy var backImg: UIImageView = {
        let img = UIImageView()
        img.image = .gradientSample
        img.clipsToBounds = true
        img.layer.cornerRadius = 20
        img.isHidden = true
        return img
    }()

    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        return view
    }()

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

    override var isSelected: Bool {
        didSet {
            if isSelected {
                backImg.isHidden = false
            } else {
                backImg.isHidden = true
            }
        }
    }

    override class var size: CGSize {
        let width: CGFloat = (deviceWidth - 36 - 14)/2
        let height: CGFloat = switch phoneSize {
        case .big: 130
        case .medium: 118
        case .small: 100
        }
        return CGSize(
            width: width,
            height: height
        )
    }

    override func setup() {
        super.setup()

        backgroundColor = .white
        layer.cornerRadius = cornerRadius

        layer.shadowRadius = 22
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        clipsToBounds = false

        // MARK: - Add Subviews
        addSubview(backImg)
        addSubview(backView)
        addSubview(cellIcon)
        addSubview(cellTitle)

        // MARK: - Add Constraints
        setupConstraints()
    }

    // MARK: - methods

    func configureCellData(_ data: OnboardCellModel) {
        cellTitle.text = data.title
        cellIcon.image = data.icon
    }
}

// MARK: - sizes extensions

extension OnboardCell {

    func setupConstraints() {

        backImg.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        backView.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(3)
            $0.top.equalToSuperview().offset(3)
            $0.trailing.equalToSuperview().inset(3)
            $0.bottom.equalToSuperview().inset(3)
        })

        cellIcon.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(imageTopInset)
            $0.size.equalTo(iconSize)
        })

        cellTitle.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.equalTo(cellIcon.snp.bottom).offset(8)
        })
    }
}
