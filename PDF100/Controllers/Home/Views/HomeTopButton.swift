import UIKit

final class HomeTopButton: UIView {

    var didTap: EmptyBlock?

    // MARK: - properties

    // MARK: - views

    private lazy var viewIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .white
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 18)
        return label
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
        layer.cornerRadius = 20

        layer.shadowOpacity = 1
        layer.shadowRadius = 25
        layer.shadowOffset = CGSize(width: 0, height: -5)
        layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        clipsToBounds = false

        addSubview(viewIcon)
        addSubview(titleLabel)
        addSubview(viewButton)

        setupConstraits()
    }

    func setupView(title: String, image: UIImage) {
        viewIcon.image = image
        titleLabel.text = title
    }
}

private extension HomeTopButton {

    @objc func tapView() {
        didTap?()
    }

    func setupConstraits() {
        viewIcon.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.size.equalTo(82)
        })

        titleLabel.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(76)
        })

        viewButton.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
    }
}


