import UIKit
import VisionKit
import PhotosUI
import Photos
import QuickLook
import PDFKit

protocol PreviewPresenterOutputInterface: AnyObject {
    func needUpdatePDf()
}

final class PreviewViewController: PDF100ViewController {

    private var presenter: PreviewPresenterInterface?
    private var router: PreviewRouterInterface?

    private var currentPage: Int = 1
    private var allPages: Int = 10

    private let tempName = "pdf-word-temp.pdf"
    private var originalNameFile: String = ""

    var foundSelections: [PDFSelection] = []
    var currentSelectionIndex: Int = 0

    var isSearchMode = false
    var isAddOpen = false

    var fileURL: URL!

    //MARK: - UI

    private lazy var blur: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isHidden = true
        return blurView
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.15)
        view.isHidden = true
        return view
    }()

    private lazy var importView: ImportView = {
        let view = ImportView()
        view.addCloseBtn()
        view.didTap = { index in
            self.tapAddPage(index)
        }
        view.isHidden = true
        return view
    }()

    private lazy var deleteVC: DeleteSheet = {
        let slideVC = DeleteSheet()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        slideVC.didTap = {
            self.presenter?.needDismiss()
        }
        return slideVC
    }()

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
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 25)
        return label
    }()

    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "\(trans("Page")) \(currentPage) \(trans("of")) \(allPages)"
        label.textColor = .subtitle
        label.font = .hellix(.semibold, size: 18)
        return label
    }()

    private lazy var saveButton: PdfButton = {
        let button = PdfButton()
        let normalAttributedString = NSAttributedString(
            string: trans("Save"),
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.font : UIFont.hellix(.bold, size: 18)
            ]
        )
        button.setAttributedTitle(normalAttributedString, for: .normal)
        button.setAttributedTitle(normalAttributedString, for: .highlighted)
        button.addTarget(self, action: #selector(tapSave), for: .touchUpInside)

        button.setCornerRadius(12)

        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        button.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 9)
        button.clipsToBounds = false
        return button
    }()

    private lazy var pdfView: PDFView = {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.interpolationQuality = .low
        pdfView.backgroundColor = .clear
        return pdfView
    }()

    private lazy var bottomMenu: BottomMenu = {
        let view = BottomMenu()
        view.itemCount = 4
        view.isPreviewMode = true
        view.didTap = { index in
            self.selectBottomMenu(index)
        }
        return view
    }()

    private lazy var searchView: SearchView = {
        let view =  SearchView()
        view.didChangeWord = { text in
            self.changeQuery(text)
        }
        view.isHidden = true
        return view
    }()

    private lazy var nextPrev: NextPrevView = {
        let view = NextPrevView()
        view.isHidden = true
        view.didTapNext = {
            self.showNextWord()
        }
        view.didTapPrev = {
            self.showPreviousWord()
        }
        return view
    }()

    // MARK: - Init
    init(docName: String, presenter: PreviewPresenterInterface, router: PreviewRouterInterface) {
        self.presenter = presenter
        self.router = router
        self.originalNameFile = docName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecicle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar(true)
        hideTabBar(true)
        updatePDF()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customInit()
        setPDFStart(originalNameFile)
        presenter?.viewDidLoad(withView: self)

        pdfView.delegate = self
        NotificationCenter.default.addObserver(self,
                    selector: #selector(pageDidChange(notification:)),
                      name: Notification.Name.PDFViewPageChanged,
                      object: nil)

    }

    @objc private func pageDidChange(notification: Notification) {
        guard let currentPage = pdfView.currentPage else {
            return
        }

        let page = (pdfView.document?.index(for: currentPage) ?? 0) + 1
        self.currentPage = page
        pageLabel.text = "\(trans("Page")) \(page) \(trans("of")) \(allPages)"
    }
}

// MARK: - PreviewPresenterOutputInterface

extension PreviewViewController: PreviewPresenterOutputInterface {
    func needUpdatePDf() {

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = tempName
        if let fileURL = documentsDirectory?.appendingPathComponent(fileName) {
            self.fileURL = fileURL
            let newPdfDoc = PDFDocument(url: fileURL)
            pdfView.document = newPdfDoc
            allPages = newPdfDoc?.pageCount ?? 10

            if let currentPage = pdfView.currentPage {
                let page = (pdfView.document?.index(for: currentPage) ?? 0) + 1
                self.currentPage = page
                pageLabel.text = "\(trans("Page")) \(page) \(trans("of")) \(allPages)"
            }
        }
    }
}

// MARK: - Private

private extension PreviewViewController {

    func changeQuery(_ text: String) {
        if let document = pdfView.document {
            highlightAndCountWord(text, in: document)
        }
    }

    func selectBottomMenu(_ index: Int) {
        switch index {
        case 0:
            isSearchMode.toggle()
            if !isSearchMode {
                nextPrev.isHidden = true
                searchView.clearAll()
            }
            searchView.isHidden = !isSearchMode
            pdfView.snp.updateConstraints({
                $0.top.equalTo(pageLabel.snp.bottom).offset(isSearchMode ? 70 : 30)
            })
        case 1:
            presenter?.selectReorder(name: originalNameFile)
        case 2:
            let previewController = QLPreviewController()
            previewController.dataSource = self
            self.present(previewController, animated: true, completion: nil)
        case 3:
            isAddOpen.toggle()
            blur.isHidden = !isAddOpen
            overlayView.isHidden = !isAddOpen
            importView.isHidden = !isAddOpen
        default: return
        }
    }

    @objc func tapBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presenter?.needShowDelete(sheet: deleteVC)
    }

    @objc func tapSave() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UserDefSettings.isWasGoodMove = true
        saveFile()
        presenter?.needDismiss()
    }

    func removeAnnotationsFromPDF() {
        guard let pdfDoc = pdfView.document else { return }
        for index in 0..<pdfDoc.pageCount {
            guard let page = pdfDoc.page(at: index) else { continue }
            while !page.annotations.isEmpty {
                page.removeAnnotation(page.annotations.first!)
            }
        }
    }

    func highlightAndCountWord(_ word: String, in document: PDFDocument) {
        foundSelections.removeAll()
        removeAnnotationsFromPDF()

        for pageIndex in 0..<document.pageCount {
            if let page = document.page(at: pageIndex) {
                let content = page.string ?? ""
                var range = content.range(of: word, options: .caseInsensitive)

                while let foundRange = range {
                    let nsRange = NSRange(foundRange, in: content)
                    if let selection = page.selection(for: nsRange) {
                        foundSelections.append(selection)
                        let highlight = PDFAnnotation(bounds: selection.bounds(for: page), forType: .highlight, withProperties: nil)
                        highlight.color = UIColor.buttonGradientStart.withAlphaComponent(0.6)
                        page.addAnnotation(highlight)
                    }
                    let startIndex = content.index(after: foundRange.lowerBound)
                    range = content.range(of: word, options: .caseInsensitive, range: startIndex..<content.endIndex)
                }
            }
        }

        if !foundSelections.isEmpty {
            nextPrev.isHidden = false
            currentSelectionIndex = 0
            pdfView.setCurrentSelection(foundSelections[currentSelectionIndex], animate: true)
            searchView.setWord(current: 1, all: foundSelections.count)
        } else {
            searchView.setWord(current: 0, all: 0)
            nextPrev.isHidden = true
        }
    }

    func highlightCurrentWord() {
        if !foundSelections.isEmpty {
            let selection = foundSelections[currentSelectionIndex]
            pdfView.setCurrentSelection(selection, animate: true)
            pdfView.go(to: selection.pages.first!)
        }
    }

    func showNextWord() {
        if !foundSelections.isEmpty {
            if currentSelectionIndex != foundSelections.count - 1 {
                currentSelectionIndex = (currentSelectionIndex + 1) % foundSelections.count
                highlightCurrentWord()
                searchView.setWord(current: currentSelectionIndex + 1, all: foundSelections.count)
                if currentSelectionIndex == foundSelections.count - 1 {
                    nextPrev.setNext(false)
                    nextPrev.setPrev(true)
                } else if currentSelectionIndex != 0 {
                    nextPrev.setNext(true)
                    nextPrev.setPrev(true)
                } else {
                    nextPrev.setNext(true)
                    nextPrev.setPrev(false)
                }
            }
        }
    }

    func showPreviousWord() {
        if !foundSelections.isEmpty {
            if currentSelectionIndex != 0 {
                currentSelectionIndex = (currentSelectionIndex - 1 + foundSelections.count) % foundSelections.count
                highlightCurrentWord()
                searchView.setWord(current: currentSelectionIndex + 1, all: foundSelections.count)
                if currentSelectionIndex != 0 {
                    nextPrev.setPrev(true)
                    nextPrev.setNext(true)
                } else if currentSelectionIndex == foundSelections.count - 1 {
                    nextPrev.setPrev(true)
                    nextPrev.setNext(false)
                } else {
                    nextPrev.setPrev(false)
                    nextPrev.setNext(true)
                }
            }
        }
    }

    func saveFile() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let tempUrl = documentsDirectory?.appendingPathComponent(tempName),
           let destinationPath = documentsDirectory?.appendingPathComponent("\(originalNameFile).pdf") {
            try? FileManager.default.removeItem(at: destinationPath)
            try? FileManager.default.copyItem(at: tempUrl, to: destinationPath)
        }
    }

    func tapAddPage(_ index: Int) {
        importView.isHidden = true
        blur.isHidden = true
        overlayView.isHidden = true
        bottomMenu.returnDefaultPreview()
        isAddOpen = false

        switch index {
        case 0: checkCameraPermission()
        case 1: checkPhotoLibraryPermission()
        case 2: selectPDF()
        case 10: return
        default: return
        }
    }
}

// MARK: - UISetup

private extension PreviewViewController {
    func setPDFStart(_ name: String) {
        titleLabel.text = name
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = "\(name).pdf"
        if let fileURL = documentsDirectory?.appendingPathComponent(fileName),
           let destinationPath = documentsDirectory?.appendingPathComponent(tempName) {
            try? FileManager.default.removeItem(at: destinationPath)
            try? FileManager.default.copyItem(at: fileURL, to: destinationPath)
        }
        updatePDF()
    }

    func updatePDF() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = tempName
        if let fileURL = documentsDirectory?.appendingPathComponent(fileName) {
            self.fileURL = fileURL
            let newPdfDoc = PDFDocument(url: fileURL)
            pdfView.document = newPdfDoc
            allPages = newPdfDoc?.pageCount ?? 10
            pageLabel.text = "\(trans("Page")) \(currentPage) \(trans("of")) \(allPages)"
        }
    }

    func customInit() {
        view.addSubview(backButton)
        view.addSubview(saveButton)
        view.addSubview(titleLabel)
        view.addSubview(pageLabel)
        view.addSubview(pdfView)
        view.addSubview(searchView)
        view.addSubview(nextPrev)

        view.addSubview(blur)
        view.addSubview(overlayView)
        view.addSubview(importView)

        view.addSubview(bottomMenu)

        blur.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        overlayView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        backButton.snp.makeConstraints({
            $0.size.equalTo(38)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(15)
        })

        let width = trans("Save").widthOfString(usingFont: .hellix(.bold, size: 18))
        saveButton.snp.makeConstraints({
            if currentLocal.contains("de") {
                $0.trailing.equalToSuperview().inset(10)
            } else {
                $0.trailing.equalToSuperview().inset(16)
            }
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.height.equalTo(34)
            $0.width.equalTo(width + 30)
        })

        titleLabel.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(19)
            $0.leading.equalToSuperview().offset(80)
            if currentLocal.contains("de") {
                $0.leading.equalToSuperview().offset(80)
                $0.trailing.equalToSuperview().inset(128)
            } else {
                $0.leading.equalToSuperview().offset(60)
                $0.trailing.equalTo(saveButton.snp.leading).inset(-10)
            }
        })

        pageLabel.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalTo(saveButton.snp.leading).inset(-6)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        })

        searchView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(pageLabel.snp.bottom).offset(20)
            $0.height.equalTo(40)
        })

        pdfView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(pageLabel.snp.bottom).offset(30)
            $0.bottom.equalToSuperview()
        })

        bottomMenu.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(78)
            $0.bottom.equalToSuperview().offset(isSmallPhone ? -20 : -44)
        })

        nextPrev.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalTo(searchView.snp.bottom).offset(20)
            $0.height.equalTo(52)
            $0.width.equalTo(124)
        })

        importView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(19)
            $0.bottom.equalTo(bottomMenu.snp.top).offset(-38)
            $0.height.equalTo(178)
        })
    }
}

// MARK: - PDFViewDelegate

extension PreviewViewController: PDFViewDelegate {

}

// MARK: - UIViewControllerTransitioningDelegate
extension PreviewViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let controller = PresentationController(presentedViewController: presented,
                                                presenting: presenting,
                                                heightContainerView: 450)
        return controller
    }
}

// MARK: - QLPreviewControllerDataSource
extension PreviewViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURL as QLPreviewItem
    }
}


//MARK: - All pickers
private extension PreviewViewController {

    func convertImagesToPDF(_ images: [UIImage]) {
        guard let currentPDF = pdfView.document else { return }
        presenter?.needAddImagesToPdf(document: tempName,
                                      pdfDoc: currentPDF,
                                      images: images)
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
           case .authorized:
            DispatchQueue.main.async {
                self.scanCamera()
            }
           case .notDetermined:
               AVCaptureDevice.requestAccess(for: .video) { granted in
                   if granted {
                       DispatchQueue.main.async {
                           self.scanCamera()
                       }
                   } else {
                       self.showErrorSettingAlert(title: trans("Sorry"),
                                                  message: trans("Allow the app to access your phone's camera to scan and document"))
                   }
               }
           case .denied, .restricted:
            self.showErrorSettingAlert(title: trans("Sorry"),
                                       message: trans("Allow the app to access your phone's camera to scan and document"))
           default:
            self.showErrorSettingAlert(title: trans("Sorry"),
                                       message: trans("Allow the app to access your phone's camera to scan and document"))
           }
    }

    func scanCamera() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }

    func checkPhotoLibraryPermission() {
           switch PHPhotoLibrary.authorizationStatus() {
           case .authorized:
               DispatchQueue.main.async {
                   self.presentPhotoPicker()
               }
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

    func selectPDF() {
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

extension PreviewViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {

        var images: [UIImage] = []
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            images.append(image)
        }
        convertImagesToPDF(images)
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
extension PreviewViewController: PHPickerViewControllerDelegate {
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
            self.convertImagesToPDF(selectedImages)
        }
    }
}

//MARK: - UIDocumentPickerDelegate
extension PreviewViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let sourceUrl = urls.first else { return }

        guard let pdfFromFile = PDFDocument(url: sourceUrl),
              let pdfDoc1 = pdfView.document else {return}

        presenter?.needAddPdfToPdf(document: tempName,
                                   pdfDoc1: pdfDoc1,
                                   pdfDoc2: pdfFromFile)
    }
}
