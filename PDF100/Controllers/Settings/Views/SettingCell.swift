import UIKit

final class SettingCell: PDF100CollectionCell {
    // MARK: - properties

    private let cornerRadius: CGFloat = 24
    private let iconSize: CGFloat = 42

    // MARK: - views

    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.numberOfLines = 1
        label.font = .hellix(.bold, size: 18)
        label.textColor = .textBlack
        return label
    }()

    // MARK: - overrides

    override class var size: CGSize {
        let width: CGFloat = deviceWidth - 40
        let height: CGFloat = 68
        return CGSize(
            width: width,
            height: height
        )
    }

    override func setup() {
        super.setup()

        backgroundColor = .white
        layer.cornerRadius = cornerRadius

        layer.shadowRadius = cornerRadius
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.black.withAlphaComponent(0.04).cgColor
        clipsToBounds = false

        // MARK: - Add Subviews
        addSubview(iconView)
        addSubview(titleLabel)

        // MARK: - Add Constraints
        setupConstraints()
    }

    // MARK: - methods

    func configCell(_ data: PDF100CellModel) {
        titleLabel.text = data.title
        iconView.image = data.icon
    }

}

// MARK: - sizes extensions

extension SettingCell {

    func setupConstraints() {

        iconView.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(14)
            $0.size.equalTo(iconSize)
        })

        titleLabel.snp.makeConstraints({
            $0.leading.equalTo(iconView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        })
    }
}
