import UIKit

protocol SettingsPresenterOutputInterface: AnyObject {

}

final class SettingsViewController: PDF100ViewController {

    private var presenter: SettingsPresenterInterface?
    private var router: SettingsRouterInterface?

    // MARK: - properties

    typealias DataSource = UICollectionViewDiffableDataSource<SettingSection, PDF100CellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SettingSection, PDF100CellModel>

    private lazy var dataSource = makeDataSource()
    private var sections: [SettingSection] = SettingSection.makeSection()

    // MARK: - UI

    private lazy var iconVC: ChangeIcon = {
        let slideVC = ChangeIcon()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        return slideVC
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("Settings")
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 30)
        return label
    }()

    private lazy var bannerView: BannerView = {
        let view = BannerView()
        view.didTap = {
            self.presenter?.needShowPayWall()
        }
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.contentInset.bottom = 2
        SettingCell.register(collectionView)
        return collectionView
    }()

    init(presenter: SettingsPresenterInterface, router: SettingsRouterInterface) {
        self.presenter = presenter
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar(true)
        hideTabBar(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customInit()
        presenter?.viewDidLoad(withView: self)

        applySnapshot()
    }
}

// MARK: - SettingsPresenterOutputInterface

extension SettingsViewController: SettingsPresenterOutputInterface {

}

//MARK: - Collection

private extension SettingsViewController {

    // MARK: - makeDataSource
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) ->
                UICollectionViewCell? in
                let cell = SettingCell.getCell(collectionView, for: indexPath)
                cell.configCell(item)
                return cell
            })
        return dataSource
    }

    // MARK: - makeLayout
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()

        return UICollectionViewCompositionalLayout(sectionProvider: { [self] section, _ in
            let smallSpace: CGFloat = isSmallPhone ? 10 : 15
            return setTableLayout(size: SettingCell.size, interGroupSpace: phoneSize == .big ? 20 : smallSpace)
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

extension SettingsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: presenter?.selectIcon(sheet: iconVC)
        case 1: presenter?.selectShare()
        case 2: presenter?.selectPrivacy()
        case 3: presenter?.selectTerm()
        default: return
        }
    }
}

// MARK: - UISetup

private extension SettingsViewController {
    func customInit() {

        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(isSmallPhone ? 10 : 28)
        })

        checkPremiunUI()
    }

    func checkPremiunUI() {
        let appHudmanager = MakeDollarService.shared
        if appHudmanager.isPremium {
            bannerView.snp.removeConstraints()
            bannerView.removeFromSuperview()
            view.addSubview(collectionView)

            collectionView.snp.remakeConstraints({
                $0.top.equalTo(titleLabel.snp.bottom).offset(isSmallPhone ? 10 : 22)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            })
        } else {
            view.addSubview(bannerView)
            view.addSubview(collectionView)
            bannerView.snp.remakeConstraints({
                $0.top.equalTo(titleLabel.snp.bottom).offset(isSmallPhone ? 10 : 22)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(140)
            })

            collectionView.snp.remakeConstraints({
                $0.top.equalTo(titleLabel.snp.bottom).offset(isSmallPhone ? 170 : 183)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            })
        }
    }
}

extension SettingsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let controller = PresentationController(presentedViewController: presented,
                                                presenting: presenting,
                                                heightContainerView: 330)
        return controller
    }
}
