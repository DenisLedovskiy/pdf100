import UIKit
import VisionKit
import PhotosUI
import Photos
import QuickLook

protocol HomePresenterOutputInterface: AnyObject {
    func updateCollection(_ data: [HomeCellModel])
}

final class HomeViewController: PDF100ViewController {

    private var presenter: HomePresenterInterface?
    private var router: HomeRouterInterface?

    // MARK: - properties

    typealias DataSource = UICollectionViewDiffableDataSource<HomeSection, HomeCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeCellModel>

    private lazy var dataSource = makeDataSource()
    private var sections: [HomeSection] = [HomeSection]()

    private var selectIndexDoc = 0
    var fileURL: URL!

//    private var isConvertMenu = false

    // MARK: - UI

    private lazy var convertVC: Convert = {
        let slideVC = Convert()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        slideVC.didDocTap = {

        }
        slideVC.didImgTap = {
            self.checkPhotoLibraryPermission()
        }
        return slideVC
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("PDF editor")
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 30)
        return label
    }()

    private lazy var compressView: HomeTopButton = {
        let view = HomeTopButton()
        view.setupView(title: trans("Compressor"), image: .compressor)
        view.didTap = {
            self.selectCompressor()
        }
        return view
    }()

    private lazy var conventorView: HomeTopButton = {
        let view = HomeTopButton()
        view.setupView(title: trans("Converter"), image: .conventor)
        view.didTap = {
            self.selectConventer()
        }
        return view
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("Documents")
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 22)
        return label
    }()

    private let emptyView: HomeEmpty = {
        let view = HomeEmpty()
        view.isHidden = true
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.isScrollEnabled = true
        collectionView.contentInset.bottom = 2
        HomeCell.register(collectionView)
        return collectionView
    }()

    init(presenter: HomePresenterInterface, router: HomeRouterInterface) {
        self.presenter = presenter
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
        hideNavBar(false)
        hideTabBar(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customInit()
        presenter?.viewDidLoad(withView: self)
        tabBar?.delegateTabBar = self
    }
}

// MARK: - HomePresenterOutputInterface

extension HomeViewController: HomePresenterOutputInterface {
    func updateCollection(_ data: [HomeCellModel]) {
        guard !data.isEmpty else {
            emptyView.isHidden = false
            collectionView.isHidden = true
            return
        }
        sections = HomeSection.makeSection(data)
        applySnapshot()
    }
}

// MARK: - Private

private extension HomeViewController {

    func selectCompressor() {

    }

    func selectConventer() {
        presenter?.needShowConverMenu(sheet: convertVC)
    }
}

//MARK: - Collection

private extension HomeViewController {

    // MARK: - makeDataSource
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) ->
                UICollectionViewCell? in
                let cell = HomeCell.getCell(collectionView, for: indexPath)
                cell.configCell(item)
                return cell
            })
        return dataSource
    }

    // MARK: - makeLayout
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()

        return UICollectionViewCompositionalLayout(sectionProvider: { [self] section, _ in
            setTableLayout(size: HomeCell.size)
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

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndexDoc = indexPath.row
        showSheetAlert()
    }
}

//MARK: - CellMenu
private extension HomeViewController {
    func showSheetAlert() {
        //TODO: - vожет сделать блюр
        let alertStyle = UIAlertController.Style.actionSheet

        let alert = UIAlertController(title: "",
                                      message: trans("Select action"),
                                      preferredStyle: alertStyle)

        alert.addAction(UIAlertAction(title: trans("View file"),
                                      style: .default,
                                      handler: { [self] (UIAlertAction) in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            //TODO: - Сделать добавление документа
            self.presenter?.needShowDocument()
        }))
        alert.addAction(UIAlertAction(title: trans("Edit file"),
                                      style: .default,
                                      handler:{ (UIAlertAction) in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            if let identifier = self.dataSource.itemIdentifier(for: IndexPath(row: self.selectIndexDoc, section: 0)) {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let fileName = "\(identifier.title).pdf"
                guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return}

                self.fileURL = fileURL
                let previewController = QLPreviewController()
                previewController.dataSource = self
                self.present(previewController, animated: true, completion: nil)
            }

        }))
        alert.addAction(UIAlertAction(title: trans("Share"),
                                      style: .default,
                                      handler:{ [self] (UIAlertAction)in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            presenter?.needShare(selectIndexDoc)
        }))
        alert.addAction(UIAlertAction(title: trans("Delete"),
                                      style: .destructive,
                                      handler:{ [self] (UIAlertAction)in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            presenter?.needDeleteDoc(selectIndexDoc)
        }))

        alert.addAction(UIAlertAction(title: trans("Cancel"),
                                      style: .cancel,
                                      handler: nil))

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: { })
        }
    }
}

// MARK: - UISetup

private extension HomeViewController {
    func customInit() {

        view.addSubview(titleLabel)
        view.addSubview(compressView)
        view.addSubview(conventorView)
        view.addSubview(emptyView)
        view.addSubview(headerLabel)
        view.addSubview(collectionView)

        titleLabel.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(isSmallPhone ? 10 : 28)
        })

        compressView.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(34)
            $0.leading.equalToSuperview().offset(19)
            $0.height.equalTo(118)
            $0.trailing.equalTo(view.snp.centerX).offset(-7)
        })

        conventorView.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(34)
            $0.trailing.equalToSuperview().inset(19)
            $0.height.equalTo(118)
            $0.leading.equalTo(view.snp.centerX).offset(7)
        })

        headerLabel.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(19)
            $0.top.equalTo(conventorView.snp.bottom).offset(24)
        })

        emptyView.snp.makeConstraints({
            $0.top.equalTo(headerLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        })

        collectionView.snp.makeConstraints({
            $0.top.equalTo(headerLabel.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        })
    }
}

//MARK: - All pickers
private extension HomeViewController {

    func convertImagesToPDF(_ images: [UIImage]) {
        presenter?.createPDFFromImg(images)
    }

    func showCamera() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
           case .authorized:
            DispatchQueue.main.async {
                self.showCamera()
            }
           case .notDetermined:
               AVCaptureDevice.requestAccess(for: .video) { granted in
                   if granted {
                       DispatchQueue.main.async {
                           self.showCamera()
                       }
                   } else {
                       self.showErrorSettingAlert(title: trans("Sorry"),
                                                  message: trans("Allow the app to access your phone's camera to scan and document."))
                   }
               }
           case .denied, .restricted:
            self.showErrorSettingAlert(title: trans("Sorry"),
                                       message: trans("Allow the app to access your phone's camera to scan and document."))
           default:
            self.showErrorSettingAlert(title: trans("Sorry"),
                                       message: trans("Allow the app to access your phone's camera to scan and document."))
           }
    }


    func checkPhotoLibraryPermission() {
           switch PHPhotoLibrary.authorizationStatus() {
           case .authorized:
               presentPhotoPicker()
           case .notDetermined:
               PHPhotoLibrary.requestAuthorization { status in
                   DispatchQueue.main.async {
                       if status == .authorized {
                           self.presentPhotoPicker()
                       } else {
                           self.showErrorSettingAlert(title: trans("Sorry"),
                                                      message: trans("For this feature to work, please allow access to the gallery"))
                       }
                   }
               }
           default:
               self.showErrorSettingAlert(title: trans("Sorry"),
                                          message: trans("For this feature to work, please allow access to the gallery"))
           }
       }

    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0
        configuration.selection = .ordered

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func pickFile() {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf],
            asCopy: true
        )
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }

}

//MARK: - VNDocumentCameraViewControllerDelegate

extension HomeViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {

        var images: [UIImage] = []
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            images.append(image)
        }
        if !images.isEmpty {
            convertImagesToPDF(images)
        }
        dismiss(animated: true)
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        dismiss(animated: true)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("Ошибка сканирования: \(error)")
        dismiss(animated: true)
    }
}

//MARK: - PHPickerViewControllerDelegate
extension HomeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        var selectedImages: [UIImage] = []

        let itemProviders = results.map { $0.itemProvider }
        let group = DispatchGroup()

        for item in itemProviders {
            group.enter()
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let image = object as? UIImage {
                        selectedImages.append(image)
                    }
                    group.leave()
                }
            } else {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if !selectedImages.isEmpty {
                self.convertImagesToPDF(selectedImages)
            }
        }
    }
}

//MARK: - UIDocumentPickerDelegate
extension HomeViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let sourceUrl = urls.first,
              let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let originalFileName = sourceUrl.lastPathComponent
        let uniqueFileName = getUniqueFileName(originalFileName, in: documentsUrl)
        let destinationUrl = documentsUrl.appendingPathComponent(uniqueFileName)

        do {
            try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
            presenter?.addPDF(uniqueFileName)
        } catch {
            print(error.localizedDescription)
        }
    }

    func getUniqueFileName(_ fileName: String, in directory: URL) -> String {
        var currentFileName = fileName
        var index = 1

        while fileExists(at: directory.appendingPathComponent(currentFileName)) {
            currentFileName = appendIndexToFileName(fileName, index: index)
            index += 1
        }

        return currentFileName
    }

    private func appendIndexToFileName(_ fileName: String, index: Int) -> String {
        let components = fileName.components(separatedBy: ".")
        let baseName = components.first
        let extensionName = components.count > 1 ? "." + components.dropFirst().joined(separator: ".") : ""
        return "\(baseName ?? "docName")(\(index))\(extensionName)"
    }

    private func fileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
}

//MARK: - AppTabBarDelegate
extension HomeViewController: AppTabBarDelegate {
    func appTabBarDidTapMenu(_ index: Int) {
        switch index {
        case 0:
            checkCameraPermission()
        case 1:
            checkPhotoLibraryPermission()
        case 2:
            pickFile()
        default: return
        }
    }
}

// MARK: - QLPreviewControllerDataSource
extension HomeViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURL as QLPreviewItem
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension HomeViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let controller = PresentationController(presentedViewController: presented,
                                                presenting: presenting,
                                                heightContainerView: 250)
        return controller
    }
}
