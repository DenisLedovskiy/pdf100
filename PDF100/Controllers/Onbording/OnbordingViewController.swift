import UIKit
import StoreKit
import SafariServices

final class OnbordingViewController: PDF100ViewController {

    private let appHubManager = MakeDollarService.shared

    private var screenIndex = 0
    private lazy var bottomButtonsHeight: Double = 20

    private var imageTopInset: Double = switch phoneSize {
    case .small: 135
    case .medium: 195
    case .big: 225
    }

    private var imageHeight: Double = switch phoneSize {
    case .small: (deviceWidth-20) * 1.13 //1.18066
    case .medium: 446
    case .big: deviceWidth * 1.1348
    }

    private var titleTopInset: Double = switch phoneSize {
    case .small: 20
    case .medium: isEnLocal ? 80 : 40
    case .big: isEnLocal ? 80 : 60
    }

    private var bottomButtonsInset: Double = switch phoneSize {
    case .small: 6
    case .medium: 12
    case .big: 14
    }

    // MARK: - properties

    typealias DataSource = UICollectionViewDiffableDataSource<OnboardSection, OnboardCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<OnboardSection, OnboardCellModel>

    private lazy var dataSource = makeDataSource()
    private var sections: [OnboardSection] = OnboardSection.makeFirstSection()

    //MARK: - UI
    private let bigImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .subtitle
        label.font = .hellix(.semibold, size: 16)
        return label
    }()

    private lazy var continueButton: PdfButton = {
        let button = PdfButton()
        button.setTitle(trans("Continue"))
        button.addTarget(self, action: #selector(setNext), for: .touchUpInside)

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

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.contentInset.bottom = 2
        OnboardCell.register(collectionView)
        collectionView.isHidden = true
        collectionView.layer.masksToBounds = false
        return collectionView
    }()
    
    //MARK: - Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        customInit()
        hideTabBar(true)
        hideNavBar(true)
        applySnapshot()
        appHubManager.delegate = self
    }
}

//MARK: - Action
private extension OnbordingViewController {

    @objc func setNext() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        screenIndex += 1

        if screenIndex == 2 {
            rateApp()
            getAppHudInfoAgain()
        }

        if screenIndex == 3 {
            bigImageView.isHidden = true
            collectionView.isHidden = false
            sections = OnboardSection.makeFirstSection()
            applySnapshot()
        }

        if screenIndex == 4 {
            sections = OnboardSection.makeSecondSection()
            applySnapshot()
        }

        if screenIndex < 5 {
            changeUI(screenIndex)
        } else {
            navigateToPayWall()
        }
    }

    @objc func selectPP() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        guard let url = URL(string: Config.privacy.rawValue) else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }

    @objc func selectRestore() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        startSpinner()
        appHubManager.restore()
    }

    @objc func selectTerm() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        guard let url = URL(string: Config.term.rawValue) else {
          return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
}

//MARK: - Private
private extension OnbordingViewController {

    func changeUI(_ index: Int) {
        setTitle(index)
//        switch index {
//        case 0: subLabel.text = trans("Facilitates fast and precise PDF file adjustments")
//        case 1: subLabel.text = trans("Gives you the tools to swiftly and precisely adjust PDFs")
//        case 2: subLabel.text = trans("We're committed to delivering the best experience for you")
//        case 3: subLabel.text = trans("Take a moment to indicate which one you would prefer")
//        case 4: subLabel.text = trans("You may select multiple options from the following list")
//        default: return
//        }

        let text = switch index {
        case 0: trans("Facilitates fast and precise PDF file adjustments")
        case 1: trans("Gives you the tools to swiftly and precisely adjust PDFs")
        case 2: trans("We're committed to delivering the best experience for you")
        case 3: trans("Take a moment to indicate which one you would prefer")
        case 4: trans("You may select multiple options from the following list")
        default: ""
        }

        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        subLabel.attributedText = attributedText
        subLabel.textAlignment = .center

        if screenIndex < 3 {
            bigImageView.image = UIImage(named: "onboradImg.\(index)")
        }
    }

    func rateApp() {
        if let scene = UIApplication.shared.currentScene {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview()
            }
        }
    }

    func navigateToPayWall() {
        let controller = PayWallInit.createViewController()
        navigationController?.pushViewController(controller, animated: false)
    }

    func getAppHudInfoAgain() {
        Task {
            MakeDollarService.shared.getProducts()
        }
    }
}

//MARK: - Collection

private extension OnbordingViewController {

    // MARK: - makeDataSource
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) ->
                UICollectionViewCell? in
                let cell = OnboardCell.getCell(collectionView, for: indexPath)
                cell.configureCellData(item)
                return cell
            })
        return dataSource
    }

    // MARK: - makeLayout
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()

        return UICollectionViewCompositionalLayout(sectionProvider: { [self] section, _ in
            setGridLayout(size: OnboardCell.size, countItems: 2)
        }, configuration: configuration)
    }

    private func applySnapshot(animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        DispatchQueue.main.async() {
            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
}

//MARK: - UICollectionViewDelegate

extension OnbordingViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}

//MARK: - Constraits and UI
private extension OnbordingViewController {
    func customInit() {
        navigationController?.navigationBar.isHidden = true
        setConstraits()
        changeUI(screenIndex)
    }

    func setConstraits() {
        view.addSubview(bigImageView)
        view.addSubview(collectionView)
        view.addSubview(titleLabel)
        view.addSubview(subLabel)
        view.addSubview(continueButton)

        view.addSubview(ppButton)
        view.addSubview(termButton)
        view.addSubview(restoreButton)

        titleLabel.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(10)
        })

        subLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(isSmallPhone ? 6 : 8)
            if isEnLocal {
                $0.leading.trailing.equalToSuperview().inset(isSmallPhone ? 40 : 60)
            } else {
                $0.leading.trailing.equalToSuperview().inset(isSmallPhone ? 20 : 40)
            }
        })

        bigImageView.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(imageTopInset)
            $0.leading.trailing.equalToSuperview().inset(isSmallPhone ? 10 : 0)
            $0.height.equalTo(imageHeight)
        })

        collectionView.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(imageTopInset + 20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(imageHeight)
        })

        continueButton.snp.makeConstraints({
            $0.top.equalTo(bigImageView.snp.bottom).offset(0)
            $0.height.equalTo(continueButton.height)
            $0.leading.trailing.equalToSuperview().inset(22)
        })

        let space: CGFloat = isEnLocal ? 120 : 20
        let downWidth = (deviceWidth - space)/3
        restoreButton.snp.makeConstraints({
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bottomButtonsInset)
            $0.leading.equalToSuperview().offset(space/2)
            $0.height.equalTo(bottomButtonsHeight)
            $0.width.equalTo(downWidth - 10)
        })

        termButton.snp.makeConstraints({
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bottomButtonsInset)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(bottomButtonsHeight)
            $0.width.equalTo(downWidth + 10)
        })

        ppButton.snp.makeConstraints({
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-bottomButtonsInset)
            $0.trailing.equalToSuperview().inset(space/2)
            $0.height.equalTo(bottomButtonsHeight)
            $0.width.equalTo(downWidth - 10)
        })
    }

    private func setTitle(_ index: Int) {
        let style1 = [NSAttributedString.Key.font : UIFont.hellix(.bold, size: 30),
                      NSAttributedString.Key.foregroundColor : UIColor.textBlack]
        let style2 = [NSAttributedString.Key.font : UIFont.hellix(.bold, size: 30),
                      NSAttributedString.Key.foregroundColor : UIColor.textRed]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        switch index {
        case 0:
            let attrStr1 = NSMutableAttributedString(string: trans("Scan") + ", ", attributes: style1)
//            var stirng2 = trans("edit") + " "
//            if isEnLocal {
               let stirng2 = trans("edit") + "\n"
//            }
            let attrStr2 = NSMutableAttributedString(string: stirng2, attributes: style2)
            let attrStr3 = NSMutableAttributedString(string: trans("and share"), attributes: style1)
            attrStr1.append(attrStr2)
            attrStr1.append(attrStr3)

            attrStr1.addAttribute(.paragraphStyle,
                                        value: paragraphStyle,
                                        range: NSRange(location: 0, length: attrStr1.length))
            titleLabel.attributedText = attrStr1
            titleLabel.textAlignment = .center
        case 1:
//            var stirng = trans("Compress and") + " "
//            if isEnLocal {
                let stirng = trans("Compress and") + "\n"
//            }
            let attrStr1 = NSMutableAttributedString(string: stirng, attributes: style1)
            let attrStr2 = NSMutableAttributedString(string: trans("Convert") + " ", attributes: style2)
            let attrStr3 = NSMutableAttributedString(string: "PDF", attributes: style1)
            attrStr1.append(attrStr2)
            attrStr1.append(attrStr3)
            attrStr1.addAttribute(.paragraphStyle,
                                        value: paragraphStyle,
                                        range: NSRange(location: 0, length: attrStr1.length))
            titleLabel.attributedText = attrStr1
            titleLabel.textAlignment = .center
        case 2:
            let attrStr1 = NSMutableAttributedString(string: trans("Preferred") + " ", attributes: style2)
//            var stirng = trans("by users")
//            if isEnLocal {
            let   stirng = trans("by\n users")
//            }
            let attrStr2 = NSMutableAttributedString(string: stirng, attributes: style1)
            attrStr1.append(attrStr2)
            attrStr1.addAttribute(.paragraphStyle,
                                        value: paragraphStyle,
                                        range: NSRange(location: 0, length: attrStr1.length))
            titleLabel.attributedText = attrStr1
            titleLabel.textAlignment = .center
        case 3:
//            var stirng = trans("How would you") + " "
//            if isEnLocal {
            let  stirng = trans("How would you") + "\n"
//            }
            let attrStr1 = NSMutableAttributedString(string: stirng, attributes: style1)
            let attrStr2 = NSMutableAttributedString(string: trans("describe") + " ", attributes: style2)
            let attrStr3 = NSMutableAttributedString(string: trans("yourself") + "?", attributes: style1)
            attrStr1.append(attrStr2)
            attrStr1.append(attrStr3)
            attrStr1.addAttribute(.paragraphStyle,
                                        value: paragraphStyle,
                                        range: NSRange(location: 0, length: attrStr1.length))
            titleLabel.attributedText = attrStr1
            titleLabel.textAlignment = .center
        case 4:
//            var stirng = trans("Which feature you’ll ") + " "
//            if isEnLocal {
            let  stirng = trans("Which feature you’ll ") + "\n"
//            }
            let attrStr1 = NSMutableAttributedString(string: stirng, attributes: style1)
            let attrStr2 = NSMutableAttributedString(string: trans("use") + " ", attributes: style2)
            let attrStr3 = NSMutableAttributedString(string: trans("regularly") + "?", attributes: style1)
            attrStr1.append(attrStr2)
            attrStr1.append(attrStr3)
            attrStr1.addAttribute(.paragraphStyle,
                                        value: paragraphStyle,
                                        range: NSRange(location: 0, length: attrStr1.length))
            titleLabel.attributedText = attrStr1
            titleLabel.textAlignment = .center
        default: return
        }
    }
}

// MARK: - AppHubManagerDelegate

extension OnbordingViewController: AppHudManagerDelegate {
    func finishLoadPaywall() { }
    
    func purchasesWasEnded(success: Bool?, messageError: String) {
        endSpinner()
        guard let success = success else {
            return
        }

        if !success {
            showErrorAlert(title: trans("Sorry"), message: messageError)
        }
    }
}
