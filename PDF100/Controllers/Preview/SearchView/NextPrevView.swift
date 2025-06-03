import UIKit

final class NextPrevView: UIView {

    var didTapNext: EmptyBlock?
    var didTapPrev: EmptyBlock?

    // MARK: - properties

    // MARK: - views

    private lazy var nextBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(.nextOn, for: .normal)
        button.setImage(.nextOn, for: .highlighted)
        button.addTarget(self, action: #selector(tapNext), for: .touchUpInside)

        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 1
        button.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 9)
        button.clipsToBounds = false

        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()

    private lazy var prevBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(.prevOff, for: .normal)
        button.setImage(.prevOff, for: .highlighted)
        button.addTarget(self, action: #selector(tapPrev), for: .touchUpInside)
        button.clipsToBounds = false

        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFill
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
        layer.cornerRadius = 15

        layer.shadowOpacity = 1
        layer.shadowRadius = 11
        layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 7)
        clipsToBounds = false

        addSubview(nextBtn)
        addSubview(prevBtn)
        setupConstraits()
    }

    func setNext(_ isActive: Bool) {
        if isActive {
            nextBtn.setImage(.nextOn, for: .normal)
            nextBtn.setImage(.nextOn, for: .highlighted)
            nextBtn.layer.shadowRadius = 12
            nextBtn.layer.shadowOpacity = 1
            nextBtn.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
            nextBtn.layer.shadowOffset = CGSize(width: 0, height: 9)
            nextBtn.clipsToBounds = false
        } else {
            nextBtn.setImage(.nextOff, for: .normal)
            nextBtn.setImage(.nextOff, for: .highlighted)
            nextBtn.layer.shadowRadius = 0
            nextBtn.layer.shadowOpacity = 0
            nextBtn.layer.shadowColor = UIColor.clear.cgColor
        }
    }

    func setPrev(_ isActive: Bool) {
        if isActive {
            prevBtn.setImage(.prevOn, for: .normal)
            prevBtn.setImage(.prevOn, for: .highlighted)
            prevBtn.layer.shadowRadius = 12
            prevBtn.layer.shadowOpacity = 1
            prevBtn.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
            prevBtn.layer.shadowOffset = CGSize(width: 0, height: 9)
            prevBtn.clipsToBounds = false
        } else {
            prevBtn.setImage(.prevOff, for: .normal)
            prevBtn.setImage(.prevOff, for: .highlighted)
            prevBtn.layer.shadowRadius = 0
            prevBtn.layer.shadowOpacity = 0
            prevBtn.layer.shadowColor = UIColor.clear.cgColor
        }
    }
}

private extension NextPrevView {

    @objc func tapNext() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        didTapNext?()
    }

    @objc func tapPrev() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        didTapPrev?()
    }

    func setupConstraits() {
        nextBtn.snp.makeConstraints({
            $0.size.equalTo(33)
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        })

        prevBtn.snp.makeConstraints({
            $0.size.equalTo(33)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        })
    }
}
