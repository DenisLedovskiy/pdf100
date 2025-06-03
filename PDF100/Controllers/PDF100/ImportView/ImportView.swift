import UIKit

class ImportView: UIView {

    var didTap: ((Int)->())?

    // MARK: - properties

    typealias DataSource = UICollectionViewDiffableDataSource<ImportSection, PDF100CellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<ImportSection, PDF100CellModel>

    private lazy var dataSource = makeDataSource()
    private var sections: [ImportSection] = ImportSection.makeSection()

    // MARK: - views

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("Import from")
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 18)
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.contentInset.bottom = 2
        collectionView.layer.masksToBounds = false
        ImportCell.register(collectionView)
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

        backgroundColor = .popWhite
        layer.cornerRadius = 30

        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: -5)
        layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        clipsToBounds = false

        addSubview(titleLabel)
        addSubview(collectionView)

        setupConstraits()
        applySnapshot()
    }

    func addCloseBtn() {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(.close, for: .normal)
        button.setImage(.close, for: .highlighted)
        button.addTarget(self, action: #selector(tapClose), for: .touchUpInside)

        addSubview(button)

        button.snp.makeConstraints({
            $0.size.equalTo(32)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(16)
        })
    }

    @objc func tapClose() {
        didTap?(10)
    }
}

//MARK: - Collection

private extension ImportView {

    // MARK: - makeDataSource
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) ->
                UICollectionViewCell? in
                let cell = ImportCell.getCell(collectionView, for: indexPath)
                cell.configureCellData(item)
                return cell
            })
        return dataSource
    }

    // MARK: - makeLayout
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()

        return UICollectionViewCompositionalLayout(sectionProvider: { [self] section, _ in
            setGridLayout(size: ImportCell.size, countItems: 3)
        }, configuration: configuration)
    }

    func setGridLayout(size: CGSize,
                        interItemSpace: CGFloat = 15,
                        interGroupSpace: CGFloat = 15,
                        countItems: Int,
                        leftRightInset: CGFloat = 14,
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

extension ImportView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTap?(indexPath.row)
    }
}

private extension ImportView {

    func setupConstraits() {
        titleLabel.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(14)
            $0.top.equalToSuperview().offset(30)
        })

        collectionView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.bottom.equalToSuperview()
        })
    }
}
