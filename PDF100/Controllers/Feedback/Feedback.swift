import UIKit

final class Feedback: UIViewController {

    //MARK: - UI
    private lazy var blur: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 1
        return blurView
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.15)
        view.alpha = 1
        return view
    }()

    private let centerView: UIView = {
        let view = UIView()
        view.backgroundColor = .popWhite
        view.layer.cornerRadius = 30
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.feedbackClose, for: .normal)
        button.setImage(.feedbackClose, for: .highlighted)
        button.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
        return button
    }()

    private let bigImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.image = .feedbackIcon
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = .hellix(.bold, size: 25)
        label.textColor = .textBlack
        label.text = trans("Do you like our app?")
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .subtitle
        label.font = .hellix(.semibold, size: 18)
        let text = trans("We’d love to hear what you think about your experience with the app!")

        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        label.attributedText = attributedText
        label.textAlignment = .center
        return label
    }()

    private lazy var continueButton: PdfButton = {
        let button = PdfButton()
        let normalAttributedString = NSAttributedString(
            string: trans("Write a feedback"),
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.font : UIFont.hellix(.bold, size: 18)
            ]
        )
        button.setAttributedTitle(normalAttributedString, for: .normal)
        button.setAttributedTitle(normalAttributedString, for: .highlighted)
        button.addTarget(self, action: #selector(tapFeedback), for: .touchUpInside)

        button.setCornerRadius(24)

        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        button.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 9)
        button.clipsToBounds = false
        return button
    }()

    //MARK: - Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        customInit()
        UserDefSettings.isShowedLikeIt = true
    }
}

//MARK: - Action
private extension Feedback {

    @objc func tapBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.dismiss(animated: false)
    }

    @objc func tapFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let url = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id\(Config.appID)?action=write-review") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

//MARK: - Constraits and UI
private extension Feedback {
    func customInit() {
        navigationController?.navigationBar.isHidden = true
        setConstraits()
    }
    
    func setConstraits() {
        view.addSubview(blur)
        view.addSubview(overlayView)
        view.addSubview(centerView)
        centerView.addSubview(bigImageView)
        centerView.addSubview(backButton)
        centerView.addSubview(titleLabel)
        centerView.addSubview(subLabel)
        centerView.addSubview(continueButton)

        blur.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        overlayView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        centerView.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.height.equalTo(513)
            $0.width.equalTo(isSmallPhone ? 320 : 354)
        })

        bigImageView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(310)
        })

        backButton.snp.makeConstraints({
            $0.size.equalTo(32)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        })

        titleLabel.snp.makeConstraints({
            $0.top.equalTo(bigImageView.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        subLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(10)
        })
        
        continueButton.snp.makeConstraints({
            $0.bottom.equalToSuperview().inset(32)
            $0.height.equalTo(66)
            $0.leading.trailing.equalToSuperview().inset(22)
        })
    }
}
