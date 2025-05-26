import PDFKit
import UIKit

protocol ReorderVCDelegate: AnyObject {
    func needRefreshCollection()
    func needAddStepFromReorder()
}

final class ReorderVC: PDF100ViewController {

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

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.backBtn, for: .normal)
        button.setImage(.backBtn, for: .highlighted)
        button.addTarget(self, action: #selector(tapBack), for: .touchUpInside)

        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 25
        button.layer.shadowOffset = CGSize(width: 0, height: -5)
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        button.clipsToBounds = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = trans("Settings das dsad asd as")
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 25)
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self

        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self

        collectionView.contentInset.bottom = 50

        ReorderCell.register(collectionView)
        return collectionView
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .reorderDragTip
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()

    private lazy var backView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.image = .settBanner
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        return imageView
    }()

    private let shadowBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 1
        view.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 9)
        view.layer.masksToBounds = false
        return view
    }()

    private let descLabel: UILabel = {
       let label = UILabel()
        label.font = .hellix(.bold, size: 16)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("Drag pages to rearrange them")
        return label
    }()

    private lazy var bottomMenu: BottomMenu = {
        let view = BottomMenu()
        view.itemCount = 2
        view.isPreviewMode = false
        view.setEdit(false)
        view.didTap = { index in
            self.selectBottomMenu(index)
        }
        return view
    }()

    //MARK: -  Lifecicle

    override func viewDidLoad() {
        super.viewDidLoad()
        congifureConstraits()

        setCollectionData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isWasEdited else {return}
        delegate?.needAddStepFromReorder()
    }
}
//MARK: - Private
private extension ReorderVC {

    func selectBottomMenu(_ index: Int) {
        if index == 0 {
            rotatePages()
        } else {
            showDeleteAlert()
        }
    }

    @objc func tapBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        close()
    }

    func close() {
        dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }

    //MARK: - Rotate
    func rotateAllPagesAndSave(pdfDocument: PDFDocument, pageNumbers: [Int], saveUrl: URL) {
        for pageNumber in pageNumbers {
            guard let page = pdfDocument.page(at: pageNumber) else {
                continue
            }
        let currentRotation = page.rotation
        page.rotation = (currentRotation + 90) % 360
        }

        if pdfDocument.write(to: saveUrl) {
            setCollectionData()
            bottomMenu.setEdit(false)
            setContent(true)
        }
    }

    func rotatePages() {
        var pagesToRotate = [Int]()
        snapshot.itemIdentifiers.forEach {
            if $0.isSelect {
                if let indexPath = dataSource.indexPath(for: $0) {
                    pagesToRotate.append(indexPath.row)
                }
            }
        }

        pagesToRotate.sort(by: <)

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = nameDoc
        guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return}

        let pdfDocument = PDFDocument(url: fileURL)
        guard let document = pdfDocument else { return }

        rotateAllPagesAndSave(pdfDocument: document, pageNumbers: pagesToRotate, saveUrl: fileURL)
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
        checkIsBottomMenuActive()

        pagesToRemove.sort(by: <)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = nameDoc
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
        let fileName = nameDoc
        guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return}
        try document.write(to: fileURL)
    }

        //MARK: - SetCollection
    func setCollectionData() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = nameDoc
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
                                      message: trans("Do you want to delete pages?"),
                                      preferredStyle: alertStyle)

        alert.addAction(UIAlertAction(title: trans("Delete pages"),
                                      style: .destructive,
                                      handler: { [self] (UIAlertAction) in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            deletePages()
        }))
        alert.addAction(UIAlertAction(title: trans("Cancel"),
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
        group.interItemSpacing = .fixed(8)

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
        snapshot = Snapshot()
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

        checkIsBottomMenuActive()

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

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(shadowBackView)
        view.addSubview(backView)
        backView.addSubview(iconView)
        backView.addSubview(descLabel)
        view.addSubview(backButton)
        view.addSubview(collectionView)
        view.addSubview(bottomMenu)

        backButton.snp.makeConstraints({
            $0.size.equalTo(38)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(15)
        })

        titleLabel.snp.makeConstraints({
            $0.centerY.equalTo(backButton.snp.centerY)
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().inset(60)
        })

        shadowBackView.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(19)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(46)
        })

        backView.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(19)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(46)
        })

        iconView.snp.makeConstraints({
            $0.size.equalTo(28)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
        })

        descLabel.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconView.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(16)
        })

        collectionView.snp.makeConstraints({
            $0.top.equalTo(backView.snp.bottom).offset(19)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        })

        bottomMenu.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(78)
            $0.bottom.equalToSuperview().offset(-44)
        })
    }

    func checkIsBottomMenuActive() {
        let isActive = snapshot.itemIdentifiers.contains { $0.isSelect == true }
        bottomMenu.setEdit(isActive)
        setContent(!isActive)
    }

    func setContent(_ isDrag: Bool) {
        iconView.image = isDrag ? .reorderDragTip : .reorderDeleteTip
        descLabel.text = isDrag ? trans("Drag pages to rearrange them") : trans("You can delete or rotate files using the toolbar")
        backView.snp.updateConstraints({
            $0.height.equalTo(isDrag ? 46 : 56)
        })
        shadowBackView.snp.updateConstraints({
            $0.height.equalTo(isDrag ? 46 : 56)
        })
    }
}
