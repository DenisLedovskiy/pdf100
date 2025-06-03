import UIKit

final class PriceView: UIView {

    var didTapView: EmptyBlock?

    private let colorGradient = UIColor(patternImage: .gradientSmall)

    private var topBottomInset: Double = switch phoneSize {
    case .small: 11
    case .medium: 13
    case .big: 16
    }

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

    let dotView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.numberOfLines = 1
        label.font = .hellix(.bold, size: 18)
        label.textColor = .textBlack
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    var priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.numberOfLines = 1
        label.font = .hellix(.semibold, size: 16)
        label.textColor = .subtitle
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    var rightpPriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.numberOfLines = 1
        label.font = .hellix(.semibold, size: 16)
        label.textColor = .subtitle
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    lazy var viewButton: UIButton = {
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
        layer.cornerRadius = 20

        layer.shadowOpacity = 0.8
        layer.shadowRadius = 6
        layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 7)
        clipsToBounds = false

        addSubview(backImg)
        addSubview(backView)
        addSubview(dotView)
        addSubview(titleLabel)
        addSubview(priceLabel)
        addSubview(rightpPriceLabel)
        addSubview(viewButton)

        setupConstraits()
    }

    func setSelect(isSelect: Bool) {
        if isSelect {
            backImg.isHidden = false
            dotView.image = .pwDotOn
            priceLabel.textColor = colorGradient
        } else {
            backImg.isHidden = true
            dotView.image = .pwDotOff
            priceLabel.textColor = .subtitle
        }
    }

    func setTexts(title: String, priceDown: String, priceRight: String) {
        priceLabel.text = priceDown
        titleLabel.text = title
        rightpPriceLabel.text = priceRight
    }
}

private extension PriceView {

    @objc func tapView() {
        didTapView?()
    }

    func setupConstraits() {

        backImg.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        backView.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(3)
            $0.top.equalToSuperview().offset(3)
            $0.trailing.equalToSuperview().inset(3)
            $0.bottom.equalToSuperview().inset(3)
        })

        dotView.snp.makeConstraints({
            $0.size.equalTo(26)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(18)
        })

        titleLabel.snp.makeConstraints({
            $0.leading.equalTo(dotView.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(topBottomInset)
        })

        priceLabel.snp.makeConstraints({
            $0.leading.equalTo(dotView.snp.trailing).offset(10)
            $0.bottom.equalToSuperview().inset(topBottomInset)
        })

        rightpPriceLabel.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(25)
        })

        viewButton.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
    }
}

