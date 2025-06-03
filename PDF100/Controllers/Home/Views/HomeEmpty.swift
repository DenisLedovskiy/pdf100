import UIKit

final class HomeEmpty: UIView {

    // MARK: - properties

    // MARK: - views

    private lazy var viewIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.image = .homeEmpty
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 22)
        label.text = trans("You don’t have any document")
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .subtitle
        label.font = .hellix(.semibold, size: 16)
        let text = trans("Scan or add your document by taping the button")

        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        label.attributedText = attributedText
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        backgroundColor = .clear
        addSubview(viewIcon)
        addSubview(titleLabel)
        addSubview(subLabel)
        setupConstraits()
    }

}

private extension HomeEmpty {


    func setupConstraits() {
        viewIcon.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(isSmallPhone ? 220 : 280)
            $0.height.equalTo(isSmallPhone ? 196 : 250)
        })

        titleLabel.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(isSmallPhone ? 190 : 220)
        })

        subLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(16)
        })
    }
}


