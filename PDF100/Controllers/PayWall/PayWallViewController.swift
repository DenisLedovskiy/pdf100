import UIKit

protocol PayWallBPresenterOutputInterface: AnyObject {

}

final class PayWallViewController: PDF100ViewController {

    enum PayVariant {
        case noTrial
        case trial
    }

    private var presenter: PayWallBPresenterInterface?
    private var router: PayWallBRouterInterface?

    private var currentPlan: PayVariant = .noTrial
    private let appHubManager = MakeDollarService.shared

    // MARK: - UI Propery

    private lazy var bottomButtonsHeight: Double = 20
    private lazy var bottomFontSize: Double = isSmallPhone ? 12 : 14

    private var titleTopInset: Double = switch phoneSize {
    case .small: 20
    case .medium: 40
    case .big: isEnLocal ? 80 : 60
    }

    private var imageHeight: Double = switch phoneSize {
    case .small: 240
    case .medium: 260
    case .big: 280
    }

    private var betweenPayInset: Double = switch phoneSize {
    case .small: 10
    case .medium: 16
    case .big: 16
    }

    private var bottomContinueButtonsInset: Double = switch phoneSize {
    case .small: 40
    case .medium: 62
    case .big: 60
    }

    private var bottomButtonsInset: Double = switch phoneSize {
    case .small: 6
    case .medium: 10
    case .big: 10
    }

    private var offsetPayToImg: Double = switch phoneSize {
    case .small: 120
    case .medium: 134
    case .big: 160
    }

    private var payViewHeight: Double = switch phoneSize {
    case .small: 56
    case .medium: 66
    case .big: 74
    }

    private var imageTopInset: Double = switch phoneSize {
    case .small: 12
    case .medium: 25
    case .big: 35
    }

    // MARK: - UI
    private let topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .paywallBackground
        imageView.image = .paywallBackground
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        let style1 = [NSAttributedString.Key.font : UIFont.hellix(.bold, size: 30),
                      NSAttributedString.Key.foregroundColor : UIColor.textBlack]
        let style2 = [NSAttributedString.Key.font : UIFont.hellix(.bold, size: 30),
                      NSAttributedString.Key.foregroundColor : UIColor.textRed]

        var stirng = trans("Get started today with")
        if isEnLocal {
            stirng = trans("Get started today\n with")
        }
        let attrStr1 = NSMutableAttributedString(string: trans("Get started today with") + ", ", attributes: style1)
        let attrStr2 = NSMutableAttributedString(string: trans("full access"), attributes: style2)
        attrStr1.append(attrStr2)
        label.attributedText = attrStr1
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("Edit, sign, compress, and more—your complete PDF toolkit in one place")
        label.textColor = .subtitle
        label.font = .hellix(.semibold, size: 16)
        return label
    }()

    private lazy var continueButton: PdfButton = {
        let button = PdfButton()
        button.setTitle(trans("Continue"))
        button.addTarget(self, action: #selector(tapContinue), for: .touchUpInside)

        button.setCornerRadius(24)

        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        button.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 9)
        button.clipsToBounds = false
        return button
    }()

    private lazy var restoreButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        let normalAttributedString = NSAttributedString(
            string: trans("Restore"),
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.subtitle,
                NSAttributedString.Key.font : UIFont.hellix(.medium, size: 14)
            ]
        )
        button.setAttributedTitle(normalAttributedString, for: .normal)
        button.addTarget(self, action: #selector(selectRestore), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()

    private lazy var termButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        let normalAttributedString = NSAttributedString(
            string: trans("Terms"),
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.subtitle,
                NSAttributedString.Key.font : UIFont.hellix(.medium, size: 14)
            ]
        )
        button.setAttributedTitle(normalAttributedString, for: .normal)
        button.addTarget(self, action: #selector(selectTerm), for: .touchUpInside)
        return button
    }()

    private lazy var ppButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        let normalAttributedString = NSAttributedString(
            string: trans("Privacy"),
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.subtitle,
                NSAttributedString.Key.font : UIFont.hellix(.medium, size: 14)
            ]
        )
        button.setAttributedTitle(normalAttributedString, for: .normal)
        button.addTarget(self, action: #selector(selectPP), for: .touchUpInside)
        return button
    }()

    private lazy var notNowButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        let normalAttributedString = NSAttributedString(
            string: trans("Not now"),
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.subtitle,
                NSAttributedString.Key.font : UIFont.hellix(.medium, size: 14)
            ]
        )
        button.setAttributedTitle(normalAttributedString, for: .normal)
        button.addTarget(self, action: #selector(selectNotNow), for: .touchUpInside)

        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()

    private lazy var noTrialView: PriceView = {
        let view = PriceView()
        view.didTapView = {
            self.tapNoTrial()
        }
        return view
    }()

    private lazy var trialView: PriceView = {
        let view = PriceView()
        view.didTapView = {
            self.tapTrial()
        }
        return view
    }()

    private lazy var enableLabel: UILabel = {
        let label = UILabel()
        label.text = trans("Start Free Trial")
        label.font = .hellix(.bold, size: 16)
        label.textAlignment = .natural
        label.numberOfLines = 2
        label.textColor = .textBlack
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.isOn = false
        switchView.setOn(false, animated: false)
        switchView.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        switchView.isUserInteractionEnabled = true
        return switchView
    }()

    // MARK: - Init
    init(presenter: PayWallBPresenterInterface, router: PayWallBRouterInterface) {
        self.presenter = presenter
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - LifeCicle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(true)
        hideNavBar(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customInit()
        presenter?.viewDidLoad(withView: self)

        hideTabBar(true)
        hideNavBar(true)

        appHubManager.delegate = self
        setPriceInViews()
    }
}

// MARK: - PayWallBPresenterOutputInterface

extension PayWallViewController: PayWallBPresenterOutputInterface {

}

//MARK: - Action
private extension PayWallViewController {

    @objc func tapContinue() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        switch currentPlan {
        case .noTrial:
            guard let appHubModel = appHubManager.subscriptionNoTrial else { return }
            startSpinner()
            appHubManager.startPurchase(appHubModel)
        case .trial:
            guard let appHubModel = appHubManager.subscriptionTrial else { return }
            startSpinner()
            appHubManager.startPurchase(appHubModel)
        }
    }

    @objc func selectPP() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presenter?.selectPP()
    }

    @objc func selectRestore() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        startSpinner()
        appHubManager.restore()
    }

    @objc func selectTerm() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presenter?.selectTerm()
    }

    @objc func selectNotNow() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presenter?.selectClose()
    }

    @objc
    private func switchValueDidChange(_ sender: UISwitch?) {
        guard let sender = sender else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if sender.isOn {
            tapTrial()
        } else {
            tapNoTrial()
        }
    }

    func tapNoTrial() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        noTrialView.setSelect(isSelect: true)
        trialView.setSelect(isSelect: false)
        switchView.setOn(false, animated: true)
        currentPlan = .noTrial
        continueButton.setTitle(trans("Continue"))
    }

    func tapTrial() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        noTrialView.setSelect(isSelect: false)
        trialView.setSelect(isSelect: true)
        switchView.setOn(true, animated: true)
        currentPlan = .trial
        continueButton.setTitle(trans("Try for free"))
    }

    func setPriceInViews() {
        let priceNoTrial = appHubManager.getPrice(.noTrial)
        let durationNoTrial = appHubManager.getDuration(.noTrial)
        let perWeekPrice = appHubManager.getYearPerWeekPrice()
        noTrialView.setTexts(title: trans("Yearly"),
                             priceDown: "\(priceNoTrial)\(durationNoTrial)",
                             priceRight: "\(perWeekPrice)\(trans("/week"))")

        let priceTrial = appHubManager.getPrice(.trial)
        let durationTrial = appHubManager.getDuration(.trial)
        trialView.setTexts(title: trans("Weekly"),
                           priceDown: trans("3 days trial"),
                           priceRight: "\(priceTrial)\(durationTrial)")
    }
}

// MARK: - UISetup

private extension PayWallViewController {
    func customInit() {
        setViewAndConstraits()

        noTrialView.setSelect(isSelect: true)
        trialView.setSelect(isSelect: false)
    }

    func setViewAndConstraits() {
        view.addSubview(topImageView)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(continueButton)

        view.addSubview(ppButton)
        view.addSubview(termButton)
        view.addSubview(restoreButton)
        view.addSubview(notNowButton)

        view.addSubview(noTrialView)
        view.addSubview(trialView)

        view.addSubview(enableLabel)
        view.addSubview(switchView)

        titleLabel.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(10)
        })

        subTitleLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(isSmallPhone ? 2 : 8)
            $0.leading.trailing.equalToSuperview().inset(isSmallPhone ? 20 : 40)
        })

        topImageView.snp.makeConstraints({
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(imageTopInset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(imageHeight)
        })

        continueButton.snp.makeConstraints({
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bottomContinueButtonsInset)
            $0.height.equalTo(continueButton.height)
            $0.leading.trailing.equalToSuperview().inset(22)
        })

        let space: CGFloat = isEnLocal ? 80 : 10
        let bottomButtonWidth = (deviceWidth - space)/4
        restoreButton.snp.makeConstraints({
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bottomButtonsInset)
            $0.leading.equalToSuperview().offset(space/2)
            $0.height.equalTo(bottomButtonsHeight)
        })

        termButton.snp.makeConstraints({
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bottomButtonsInset)
            $0.leading.equalTo(restoreButton.snp.trailing)
            $0.height.equalTo(bottomButtonsHeight)
        })

        ppButton.snp.makeConstraints({
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bottomButtonsInset)
            $0.leading.equalTo(termButton.snp.trailing)
            $0.height.equalTo(bottomButtonsHeight)
        })

        notNowButton.snp.makeConstraints({
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bottomButtonsInset)
            $0.trailing.equalToSuperview().inset(space/2)
            $0.height.equalTo(bottomButtonsHeight)
        })

        if currentLocal.contains("de") {
            restoreButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth + 10)
            })
            termButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth)
            })
            ppButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth)
            })
            notNowButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth)
            })
        } else if currentLocal.contains("fr") {
            restoreButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth - 10)
            })
            termButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth - 10)
            })
            ppButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth - 10)
            })
            notNowButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth + 20)
            })
        } else {
            restoreButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth)
            })
            termButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth)
            })
            ppButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth)
            })
            notNowButton.snp.makeConstraints({
                $0.width.equalTo(bottomButtonWidth)
            })
        }

        noTrialView.snp.makeConstraints({
            $0.top.equalTo(topImageView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(22)
            $0.height.equalTo(payViewHeight)
        })

        trialView.snp.makeConstraints({
            $0.top.equalTo(noTrialView.snp.bottom).offset(betweenPayInset)
            $0.leading.trailing.equalToSuperview().inset(22)
            $0.height.equalTo(payViewHeight)
        })

        enableLabel.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().inset(150)
            $0.top.equalTo(trialView.snp.bottom).offset(betweenPayInset + 4)
        })

        switchView.snp.makeConstraints({
            $0.centerY.equalTo(enableLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(44)
        })
    }
}

// MARK: - AppHubManagerDelegate

extension PayWallViewController: AppHudManagerDelegate {
    func finishLoadPaywall() {

    }

    func purchasesWasEnded(success: Bool?, messageError: String) {
        endSpinner()
        guard let success = success else {
            return
        }
        success ? presenter?.selectClose() : showErrorAlert(title: trans("Sorry"), message: messageError)
    }
}
