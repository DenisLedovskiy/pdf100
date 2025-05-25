import UIKit

final class BannerView: UIView {

    var didTap: EmptyBlock?

    // MARK: - properties

    // MARK: - views

    private lazy var backIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.image = .settBanner
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var viewIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.image = .settIco
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = .hellix(.bold, size: 20)
        label.text = trans("PDF Editor Ultimate")
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = .hellix(.semibold, size: 16)
        label.text = trans("🔓 Unlock Full Functionality")
        return label
    }()

    private lazy var unlockButton: UIButton = {
        let button = UIButton()
        let normalAttributedString = NSAttributedString(
            string: trans("Unlock"),
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.font : UIFont.hellix(.bold, size: 16)
            ]
        )
        button.setAttributedTitle(normalAttributedString, for: .normal)
        button.setAttributedTitle(normalAttributedString, for: .highlighted)
        button.backgroundColor = .textBlack
        button.layer.cornerRadius = 10
        return button
    }()

    private lazy var viewButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(tapView), for: .touchUpInside)
        return button
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

        backgroundColor = .white
        layer.cornerRadius = 24

        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 9)
        layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
        clipsToBounds = false

        addSubview(backIcon)
        addSubview(viewIcon)
        addSubview(titleLabel)
        addSubview(subLabel)
        addSubview(unlockButton)
        addSubview(viewButton)

        setupConstraits()
    }
}

private extension BannerView {

    @objc func tapView() {
        didTap?()
    }

    func setupConstraits() {
        backIcon.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        viewIcon.snp.makeConstraints({
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(128)
        })

        titleLabel.snp.makeConstraints({
            $0.leading.equalTo(viewIcon.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(10)
        })

        subLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(viewIcon.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(10)
        })

        let width = trans("Unlock").widthOfString(usingFont: .hellix(.bold, size: 16))
        unlockButton.snp.makeConstraints({
            $0.height.equalTo(30)
            $0.width.equalTo(width + 30)
            $0.leading.equalTo(viewIcon.snp.trailing).offset(10)
            $0.bottom.equalToSuperview().inset(20)
        })
    }
}


