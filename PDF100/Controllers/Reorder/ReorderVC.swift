import PanModal
import PDFKit
import UIKit

protocol ReorderVCDelegate: AnyObject {
    func needRefreshCollection()
    func needAddStepFromReorder()
}

final class ReorderVC: UIViewController {

    weak var delegate: ReorderVCDelegate?

    var sections: [ReorderSection] = [ReorderSection]()
    lazy var dataSource = makeDataSource()

    // MARK: - Value Types
    typealias DataSource = UICollectionViewDiffableDataSource<ReorderSection, ReorderCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<ReorderSection, ReorderCellModel>

    private var snapshot = Snapshot()

    private var nameDoc = "pdf-word-temp.pdf"
    private var currentPDF: PDFDocument?

    private var isWasEdited: Bool = false

    //MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self

        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self

        ReorderCell.register(collectionView)
        return collectionView
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.buttonClose, for: .normal)
        button.setImage(.buttonClose, for: .highlighted)
        button.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
        return button
    }()

    private let bookView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .reorderBook
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()

    private let titleLabel: PLabel = {
       let label = PLabel()
        label.font = .onest(.bold, size: 22)
        label.textColor = .pBlack
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.setTitle(translate("Reorder.title"))
        return label
    }()

    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12

        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.04).cgColor
        view.clipsToBounds = false
        return view
    }()

    private let descLabel: PLabel = {
       let label = PLabel()
        label.font = .onest(.medium, size: 18)
        label.textColor = .pBlack
        label.numberOfLines = 2
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.setTitle(translate("Reorder.desc"))
        return label
    }()

    private lazy var deleteButton: PGradientButton = {
        let button = PGradientButton()
        button.addTarget(self, action: #selector(tapDelete), for: .touchUpInside)
        button.setActive(false, title: translate("Delete pages"))
        return button
    }()

    //MARK: -  Lifecicle

    override func viewDidLoad() {
        super.viewDidLoad()
        congifureConstraits()

        setCollectionData(document)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isWasEdited else {return}
        delegate?.needAddStepFromReorder()
    }

    // MARK: - Init
    init(document: PdfMainModel) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
//MARK: - Private
private extension ReorderVC {

    @objc func tapBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        close()
    }

    func close() {
        dismiss(animated: true)
    }

    @objc func tapDelete() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showDeleteAlert()
    }

    //MARK: - Delete
    func deletePages() {
        var pagesToRemove = [Int]()
        snapshot.itemIdentifiers.forEach {
            if $0.isSelect {
                if let indexPath = dataSource.indexPath(for: $0) {
                    pagesToRemove.append(indexPath.row)
                }
                snapshot.deleteItems([$0])
            }
        }
        dataSource.apply(snapshot, animatingDifferences: true)
        checkIsActiveDeleteButton()

        pagesToRemove.sort(by: <)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = "\(document.name).pdf"
        guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return}

        do {
            try removePagesFromPDF(at: fileURL, pagesToRemove: pagesToRemove)
            currentPDF = PDFDocument(url: fileURL)
        } catch {
            print("Ошибка при удалении страниц: \(error)")
        }

        isWasEdited = true
        delegate?.needRefreshCollection()
    }

    func removePagesFromPDF(at path: URL, pagesToRemove: [Int]) throws {
        let pdfDocument = PDFDocument(url: path)
        guard let document = pdfDocument else { return }
        for index in pagesToRemove.reversed() {
            if index >= document.pageCount {
                continue
            }
            document.removePage(at: index)
        }
        try document.write(to: path)
    }

    //MARK: - SwapPage

    func movePage(in document: PDFDocument,
                  fromIndex oldIndex: Int,
                  toIndex newIndex: Int) throws {

        guard let pageToMove = document.page(at: oldIndex) else {
            throw NSError(domain: "Invalid index", code: 0, userInfo: nil)
        }

        document.removePage(at: oldIndex)
        document.insert(pageToMove, at: newIndex)

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = "\(self.document.name).pdf"
        guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return}
        try document.write(to: fileURL)
    }

        //MARK: - SetCollection
    func setCollectionData(_ document: PdfMainModel) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = "\(document.name).pdf"
        guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return}
        guard let currentPDF = PDFDocument(url: fileURL) else {return}

        self.currentPDF = currentPDF
        if let images = convertPDFToImages(from: currentPDF) {
            DispatchQueue.main.async {
                self.sections = ReorderSection.makeSection(images)
                self.applySnapshot()
            }
        }
    }

    private func convertPDFToImages(from doc: PDFDocument) -> [UIImage]? {
        var images = [UIImage]()
        for index in 0...doc.pageCount-1 {

            if let page = doc.page(at: index) {
                let size = page.bounds(for: .mediaBox).size
                let image = page.thumbnail(of: size, for: .mediaBox)
                images.append(image)
            }
        }
        return images
    }
}

// MARK: - Alert
private extension ReorderVC {
    func showDeleteAlert() {
        let alertStyle = UIAlertController.Style.actionSheet

        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: alertStyle)

        alert.addAction(UIAlertAction(title: translate("Delete pages"),
                                      style: .destructive,
                                      handler: { [self] (UIAlertAction) in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            deletePages()
        }))
        alert.addAction(UIAlertAction(title: translate("Cancel"),
                                      style: .cancel,
                                      handler: nil))

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - Collection

private extension ReorderVC {

    // MARK: - makeDataSource
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) ->
                UICollectionViewCell? in
                let cell = ReorderCell.getCell(collectionView, for: indexPath)
                cell.configCell(item)
                return cell
            })
        return dataSource
    }

    // MARK: - makeLayout
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()

        return UICollectionViewCompositionalLayout(sectionProvider: { [self] section, _ in
            doGrid(size: ReorderCell.size)
        }, configuration: configuration)
    }

    func doGrid(size: CGSize) -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(size.width),
                                              heightDimension: .absolute(size.height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(size.height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(20)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 14
        section.contentInsets = .init(top: 14,
                                      leading: phoneSize == .big ? 20 : 14,
                                      bottom: 14,
                                      trailing: phoneSize == .big ? 20 : 14)
        return section
    }

    private func setSections(_ section: [ReorderSection]) {
        self.sections = section
        applySnapshot()
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

//MARK: - UICollectionViewDelegate

extension ReorderVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        var mutableItem = item
        mutableItem.isSelect.toggle()

        snapshot.deleteItems([item])

        if snapshot.itemIdentifiers.count == 0 {
            snapshot.appendItems([mutableItem])
        } else if snapshot.itemIdentifiers.count == indexPath.row {
            snapshot.insertItems([mutableItem], afterItem: snapshot.itemIdentifiers[indexPath.row - 1])
        } else {
            snapshot.insertItems([mutableItem], beforeItem: snapshot.itemIdentifiers[indexPath.row])
        }

        checkIsActiveDeleteButton()

        dataSource.apply(snapshot, animatingDifferences: true) {
            collectionView.reloadData()
        }
    }
}

extension ReorderVC: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {

        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }

        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath,
               let model = item.dragItem.localObject as? ReorderCellModel {

                print("Moving from: \(sourceIndexPath.row) to: \(destinationIndexPath.row)")

                if let document = currentPDF {
                    do {
                        try movePage(in: document,
                                     fromIndex: sourceIndexPath.row,
                                     toIndex: destinationIndexPath.row)
                    } catch {
                        print("Ошибка перемещения страницы: \(error)")
                    }
                }

                isWasEdited = true
                delegate?.needRefreshCollection()

                snapshot.deleteItems([model])

                if snapshot.numberOfItems == destinationIndexPath.row {
                    snapshot.insertItems([model], afterItem: snapshot.itemIdentifiers[destinationIndexPath.row - 1])
                } else {
                    snapshot.insertItems([model], beforeItem: snapshot.itemIdentifiers[destinationIndexPath.row])
                }

                dataSource.apply(snapshot, animatingDifferences: false)
            } else {
                print("Failed to retrieve model or sourceIndexPath.")
            }
        }
    }
}

//MARK: - UICollectionViewDragDelegate

extension ReorderVC: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let model = snapshot.itemIdentifiers[indexPath.row]
        let itemProvider = NSItemProvider(object: model.icon)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = model
        return [dragItem]
    }
}

//MARK: - UI
private extension ReorderVC {

    func congifureConstraits() {
        view.backgroundColor = .pViewBack

        view.addSubview(titleLabel)
        view.addSubview(backView)
        backView.addSubview(bookView)
        backView.addSubview(descLabel)
        view.addSubview(backButton)
        view.addSubview(deleteButton)
        view.addSubview(collectionView)

        backButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().inset(22)
            $0.top.equalToSuperview().offset(22)
            $0.size.equalTo(34)
        })

        titleLabel.snp.makeConstraints({
            $0.top.equalToSuperview().offset(33)
            $0.leading.trailing.equalToSuperview().inset(60)
        })

        backView.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(19)
            $0.leading.trailing.equalToSuperview().inset(22)
            $0.height.equalTo(75)
        })

        bookView.snp.makeConstraints({
            $0.size.equalTo(33)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
        })

        descLabel.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(bookView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
        })

        deleteButton.snp.makeConstraints({
            $0.height.equalTo(deleteButton.height)
            $0.leading.trailing.equalToSuperview().inset(22)
            $0.bottom.equalToSuperview().offset(-40)
        })

        collectionView.snp.makeConstraints({
            $0.top.equalTo(descLabel.snp.bottom).offset(19)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(deleteButton.snp.top).offset(-8)
        })
    }

    func checkIsActiveDeleteButton() {
        let isActive = snapshot.itemIdentifiers.contains { $0.isSelect == true }
        deleteButton.setActive(isActive, title: translate("Delete pages"))
    }
}

// MARK: - PanModalPresentable
extension ReorderVC: PanModalPresentable {
    var panScrollable: UIScrollView? {
        nil
    }

    var shortFormHeight: PanModalHeight {
        .maxHeight
    }

    var panModalBackgroundColor: UIColor {
        .black.withAlphaComponent(0.2)
    }

    var cornerRadius: CGFloat {
        12.0
    }

    var showDragIndicator: Bool { false }
}
