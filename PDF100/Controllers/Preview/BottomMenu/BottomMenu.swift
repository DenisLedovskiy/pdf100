import UIKit

class BottomMenu: UIView {

    var didTap: ((Int)->())?

    var isPreviewMode = true
    var currentindex: Int = 100

    // MARK: - properties

    typealias DataSource = UICollectionViewDiffableDataSource<BottomMenuSection, PDF100CellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<BottomMenuSection, PDF100CellModel>

    private lazy var dataSource = makeDataSource()
    private var sections: [BottomMenuSection] = BottomMenuSection.makePreviewSection()

    var itemCount: Int = 4

    // MARK: - views

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.contentInset.bottom = 2
        BottomMuneCell.register(collectionView)
        return collectionView
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
        layer.cornerRadius = 30

        layer.shadowOpacity = 1
        layer.shadowRadius = 21
        layer.shadowColor = UIColor.black.withAlphaComponent(0.11).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        clipsToBounds = false

        addSubview(collectionView)
        setupConstraits()
        applySnapshot()
    }

    func returnDefaultPreview() {
        currentindex = 100
        sections = BottomMenuSection.makePreviewSection()
        applySnapshot(animatingDifferences: false)
    }

    func setEdit(_ isActive: Bool) {
        currentindex = 100
        if isActive {
            sections = BottomMenuSection.makeEditOnSection()
        } else {
            sections = BottomMenuSection.makeEditSection()
        }
        applySnapshot(animatingDifferences: false)
    }
}

//MARK: - Collection

private extension BottomMenu {

    // MARK: - makeDataSource
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) ->
                UICollectionViewCell? in
                let cell = BottomMuneCell.getCell(collectionView, for: indexPath)
                cell.configureCellData(item)
                return cell
            })
        return dataSource
    }

    // MARK: - makeLayout
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()

        return UICollectionViewCompositionalLayout(sectionProvider: { [self] section, _ in
            setGridLayout(size: CGSize(width: (Int(deviceWidth) - 40)/itemCount,
                                       height: 62),
                          countItems: itemCount)
        }, configuration: configuration)
    }

    func setGridLayout(size: CGSize,
                        interItemSpace: CGFloat = 0,
                        interGroupSpace: CGFloat = 0,
                        countItems: Int,
                        leftRightInset: CGFloat = 0,
                        bottomInset: CGFloat = 0,
                        topInset: CGFloat = 0) -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(size.width),
                                              heightDimension: .absolute(size.height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(size.height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       repeatingSubitem: item,
                                                       count: countItems)
        group.interItemSpacing = .fixed(interItemSpace)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = interGroupSpace
        section.contentInsets = .init(top: topInset,
                                      leading: leftRightInset,
                                      bottom: bottomInset,
                                      trailing: leftRightInset)
        return section
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

extension BottomMenu: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        didTap?(indexPath.row)

        if isPreviewMode {
            if indexPath.row == 0 {
                if currentindex == 0 {
                    sections = BottomMenuSection.makePreviewSection()
                    applySnapshot(animatingDifferences: false)
                    currentindex = 100
                } else {
                    sections = BottomMenuSection.makeSelectPreviewSection()
                    applySnapshot(animatingDifferences: false)
                    currentindex = indexPath.row
                }
            }

            if indexPath.row == 3 {
                if currentindex == 3 {
                    sections = BottomMenuSection.makePreviewSection()
                    applySnapshot(animatingDifferences: false)
                    currentindex = 100
                } else {
                    sections = BottomMenuSection.makeSelectAddSection()
                    applySnapshot(animatingDifferences: false)
                    currentindex = indexPath.row
                }
            }
        }
    }
}

private extension BottomMenu {

    func setupConstraits() {
        collectionView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(isEnLocal ? 18 : 14)
            $0.bottom.equalToSuperview()
        })
    }
}
