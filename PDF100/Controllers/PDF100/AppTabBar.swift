import UIKit

protocol AppTabBarDelegate: AnyObject {
    func appTabBarDidTapMenu(_ index: Int)
    func cancelAnyMode()
}

final class AppTabBar: UITabBarController {

    // MARK: - Properties

    private let tabIconSize: CGFloat = 24
    private let tabHeight: CGFloat = 78

    private var isOpenMenu = false

    weak var delegateTabBar: AppTabBarDelegate?

    // MARK: - UI

    private lazy var importView: ImportView = {
        let view = ImportView()
        view.didTap = { index in
            self.hideMenu()
            self.delegateTabBar?.appTabBarDidTapMenu(index)
        }
        view.alpha = 0
        view.layer.masksToBounds = false
        return view
    }()

    private lazy var blur: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        return blurView
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.15)
        view.alpha = 0
        return view
    }()

    private lazy var centerButton: UIButton = {
        let button = UIButton()
        button.setImage(.tabBarCenter, for: .normal)
        button.setImage(.tabBarCenter, for: .highlighted)
        button.layer.cornerRadius = 41
        button.addTarget(self, action: #selector(tapCenter), for: .touchUpInside)

        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        button.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 9)
        button.clipsToBounds = false
        return button
    }()

    private let tabCustomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30

        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 25
        view.layer.shadowOffset = CGSize(width: 0, height: -5)
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        view.clipsToBounds = false
        return view
    }()

    private let homeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.image = .homeOn
        return imageView
    }()

    private let settingsIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.image = .settingsOff
        return imageView
    }()

    private let homeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .hellix(.semibold, size: 14)
        label.textColor = .textBlack
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("main")
        return label
    }()

    private let settingsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .hellix(.semibold, size: 14)
        label.textColor = .subtitle
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("Settings").lowercased()
        return label
    }()

    private lazy var homeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(tapHome), for: .touchUpInside)
        return button
    }()

    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(tapSettings), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarUI()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleQuickActionNotification(_:)),
            name: .didReceiveQuickAction,
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    deinit {
       NotificationCenter.default.removeObserver(self)
    }

    func hideTabBar(_ isHidden: Bool) {
        tabCustomView.isHidden = isHidden
        centerButton.isHidden = isHidden
        tabBar.isHidden = isHidden
    }

    func setHome() {
        selectedIndex = 0
    }

    func openMenu() {
        isOpenMenu.toggle()

        if isOpenMenu {
            self.blur.isHidden = false
            self.importView.isHidden = false
            self.overlayView.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.centerButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                self.blur.alpha = 1
                self.importView.alpha = 1
                self.overlayView.alpha = 1
            }) { finished in
                if finished {

                }
            }
        } else {
            self.importView.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.centerButton.transform = .identity
                self.blur.alpha = 0
                self.overlayView.alpha = 0
            }) { finished in
                if finished {
                    self.blur.isHidden = true
                    self.importView.isHidden = true
                    self.overlayView.isHidden = true
                }
            }
        }
    }
}

private extension AppTabBar {

    @objc func tapHome() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        selectedIndex = 0
        homeIcon.image = .homeOn
        homeLabel.textColor = .textBlack
        settingsIcon.image = .settingsOff
        settingsLabel.textColor = .subtitle
    }

    @objc func tapSettings() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        selectedIndex = 1
        homeIcon.image = .homeOff
        homeLabel.textColor = .subtitle
        settingsIcon.image = .settingsOn
        settingsLabel.textColor = .textBlack
    }

    @objc func tapCenter() {
        delegateTabBar?.cancelAnyMode()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        isOpenMenu.toggle()

        if isOpenMenu {
            self.blur.isHidden = false
            self.importView.isHidden = false
            self.overlayView.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.centerButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                self.blur.alpha = 1
                self.importView.alpha = 1
                self.overlayView.alpha = 1
            }) { finished in
                if finished {

                }
            }
        } else {
            self.importView.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.centerButton.transform = .identity
                self.blur.alpha = 0
                self.overlayView.alpha = 0
            }) { finished in
                if finished {
                    self.blur.isHidden = true
                    self.importView.isHidden = true
                    self.overlayView.isHidden = true
                }
            }
        }
    }

    func hideMenu() {
        isOpenMenu = false
        self.centerButton.transform = .identity
        self.blur.alpha = 0
        self.overlayView.alpha = 0
        self.importView.alpha = 0
        self.blur.isHidden = true
        self.importView.isHidden = true
        self.overlayView.isHidden = true
    }

    func setupTabBarUI() {
        tabBar.backgroundColor = .clear

        view.addSubview(blur)
        view.addSubview(overlayView)

        view.addSubview(tabCustomView)
        view.addSubview(centerButton)
        view.addSubview(importView)
        tabCustomView.addSubview(homeIcon)
        tabCustomView.addSubview(homeLabel)
        tabCustomView.addSubview(settingsIcon)
        tabCustomView.addSubview(settingsLabel)
        tabCustomView.addSubview(homeButton)
        tabCustomView.addSubview(settingsButton)

        overlayView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        tabCustomView.snp.makeConstraints({
            $0.height.equalTo(tabHeight)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(isSmallPhone ? 20 : 44)
        })

        centerButton.snp.makeConstraints({
            $0.size.equalTo(82)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(tabCustomView.snp.top).offset(-28)
        })

        importView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(19)
            $0.bottom.equalTo(centerButton.snp.top).offset(-14)
            $0.height.equalTo(200)
        })

        let centerCorner: CGFloat = (deviceWidth - 40)/4
        let halfIcon: CGFloat = tabIconSize/2
        let inset: CGFloat = centerCorner - halfIcon

        homeIcon.snp.makeConstraints({
            $0.size.equalTo(tabIconSize)
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(inset - 20)
        })

        homeLabel.snp.makeConstraints({
            $0.top.equalTo(homeIcon.snp.bottom).offset(6)
            $0.centerX.equalTo(homeIcon.snp.centerX)
        })

        homeButton.snp.makeConstraints({
            $0.top.equalTo(homeIcon.snp.top)
            $0.centerX.equalTo(homeIcon.snp.centerX)
            $0.size.equalTo(60)
        })

        settingsIcon.snp.makeConstraints({
            $0.size.equalTo(tabIconSize)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(inset - 20)
        })

        settingsLabel.snp.makeConstraints({
            $0.top.equalTo(settingsIcon.snp.bottom).offset(2)
            $0.centerX.equalTo(settingsIcon.snp.centerX)
        })

        settingsButton.snp.makeConstraints({
            $0.top.equalTo(settingsIcon.snp.top)
            $0.centerX.equalTo(settingsIcon.snp.centerX)
            $0.size.equalTo(60)
        })
    }
}

private extension AppTabBar {
    @objc private func handleQuickActionNotification(_ notification: Notification) {
        guard let action = notification.object as? QuikManager.Action,
              action == .openSubscription else {
            return
        }
        // Сразу открываем paywall
        showSubscription()

        // Сбрасываем флаг, чтобы не показывать снова
        QuikManager.shared.quickAction = nil
    }

    func showSubscription() {
        let viewController = PayWallInit.createViewController()

        if let navigationController = self.navigationController {
            navigationController.pushViewController(viewController, animated: false)
         } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: false)
         }
    }
}
