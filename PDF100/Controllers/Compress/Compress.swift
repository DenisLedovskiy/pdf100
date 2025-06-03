import PDFKit
import UIKit

final class Compress: PDF100ViewController {

    private var docName: String

    private let client = APIClient2()

    private var currentPercent = 30

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
        label.text = trans("Compressor")
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 25)
        return label
    }()

    private let sizeLabel: UILabel = {
       let label = UILabel()
        label.textColor = .subtitle
        label.font = .hellix(.semibold, size: 18)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var pdfView: PDFView = {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.interpolationQuality = .low
        pdfView.backgroundColor = .clear
        return pdfView
    }()

    private lazy var sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()

    private let borderView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .settBanner
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 18
        return imageView
    }()

    private lazy var blueView: UIView = {
        let view = UIView()
        view.backgroundColor = .fillBlue
        view.layer.cornerRadius = 18
        return view
    }()

    private let lightImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .light
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()

    private let lightLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .natural
//        label.text = trans("By increasing the quality, you increase the file size")
        label.textColor = .textBlack
        label.font = .hellix(.semibold, size: 16)
        label.adjustsFontSizeToFitWidth = true

        let attributedText = NSMutableAttributedString(string: trans("By increasing the quality, you increase the file size"))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedText.addAttribute(.paragraphStyle,
                                    value: paragraphStyle,
                                    range: NSRange(location: 0,
                                                   length: attributedText.length))
        label.attributedText = attributedText
        return label
    }()

    private let quailityLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.text = trans("Quality")
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 20)
        return label
    }()

    private let percentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.text = "30%"
        label.textColor = .textBlack
        label.font = .hellix(.bold, size: 20)
        return label
    }()

    private lazy var compressButton: PdfButton = {
        let button = PdfButton()
        let normalAttributedString = NSAttributedString(
            string: trans("Compress file"),
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.font : UIFont.hellix(.bold, size: 18)
            ]
        )
        button.setAttributedTitle(normalAttributedString, for: .normal)
        button.setAttributedTitle(normalAttributedString, for: .highlighted)
        button.addTarget(self, action: #selector(tapCompress), for: .touchUpInside)

        button.setCornerRadius(24)

        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        button.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 9)
        button.clipsToBounds = false
        return button
    }()

    private lazy var qualitySlider: CustomSlider = {
        let slider = CustomSlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 30
        slider.minimumTrackTintColor = UIColor(patternImage: .gradientSample)
        slider.maximumTrackTintColor = .sliderGray
        slider.addTarget(self, action: #selector(sliderChange(slider:event:)), for: .valueChanged)
        return slider
    }()

    private let loaderView: CompressLoaderView = {
        let view = CompressLoaderView()
        view.isHidden = true
        return view
    }()

    // MARK: - Init
    init(docName: String) {
        self.docName = docName
        print("Start name = \(self.docName)")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: -  Lifecicle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar(true)
        hideTabBar(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        congifureConstraits()

        updatePDF()
        hideTabBar(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}
//MARK: - Private
private extension Compress {

    @objc func tapBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        close()
    }

    func close() {
        dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }

    @objc func tapCompress() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//        let fileName = "\(docName).pdf"
//        if let fileURL = documentsDirectory?.appendingPathComponent(fileName) {
//            uploadFile(url: fileURL)
//        }
        showLoader(true)
    }

    func showLoader( _ isShow: Bool) {
        DispatchQueue.main.async {
            self.loaderView.isHidden = !isShow
            self.loaderView.startIndicator(isShow)
        }
    }

    //MARK: - Slider
    @objc func sliderChange(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began: return
            case .moved:
                let rounded = slider.value.rounded()
                let intPercent = Int(rounded)
                percentLabel.text = "\(intPercent)%"
                currentPercent = intPercent
            case .ended: return
            default:
                break
            }
        }
    }

    private func uploadFile(url: URL) {
        let fileName = url.lastPathComponent
        client.fetchPreSignedUrl(for: fileName) { preSignedUrl, finalUrl in
            guard let preSignedUrl = preSignedUrl, let finalUrl = finalUrl else {
                print("Ошибка получения preSignedUrl")
                self.showLoader(false)
                return
            }
            self.client.uploadFile(to: preSignedUrl, fileURL: url) { success in
                if success {
                    print("Файл успешно загружен! Финальная ссылка: \(finalUrl)")
                    self.startCompression(from: finalUrl,
                                          quality: self.currentPercent)
                } else {
                    print("Ошибка загрузки файла.")
                    self.showLoader(false)
                }
            }
        }
    }

    private func startCompression(from url: String, quality: Int) {
        client.compressPdf(fromUrl: url, compressionQuality: quality) { compressedUrl, error in
            if let error = error {
                print("Ошибка сжатия:", error)
                self.showLoader(false)
                return
            }

            guard let compressedUrl = compressedUrl else {
                print("Невозможно получить URL сжатого файла.")
                self.showLoader(false)
                return
            }

            print("Сжатый файл доступен по ссылке:", compressedUrl)
            self.downloadCompressedPdf(from: compressedUrl)
        }
    }

    private func downloadCompressedPdf(from url: String) {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        client.downloadPdf(fromUrl: url, saveTo: documentsDir) { fileUrl, error in
            if let error = error {
                print("Ошибка скачивания:", error.localizedDescription)
                self.showLoader(false)
                return
            }
            guard let fileUrl = fileUrl else {
                print("Файл не найден после скачивания.")
                self.showLoader(false)
                return
            }
            let oldPDFUrl = fileUrl
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileName = "\(self.docName).pdf"
            if let fileURL = documentsDirectory?.appendingPathComponent(fileName) {
                try? FileManager.default.removeItem(at: fileURL)
                try? FileManager.default.moveItem(at: oldPDFUrl, to: fileURL)
            }

            UserDefSettings.isWasGoodMove = true
            DispatchQueue.main.async {
                self.showLoader(false)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

//MARK: - UI
private extension Compress {

    func updatePDF() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = "\(docName).pdf"
        if let fileURL = documentsDirectory?.appendingPathComponent(fileName) {
            let newPdfDoc = PDFDocument(url: fileURL)
            pdfView.document = newPdfDoc
        }
        sizeLabel.text = humanReadableSize(from: docName)
    }

    func humanReadableSize(from docName: String) -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = "\(docName).pdf"
        guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return ""}

        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        guard let sizeInBytes = fileAttributes?[.size] as? Int64 else { return "" }
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useMB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: sizeInBytes)
    }

    func congifureConstraits() {

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(sizeLabel)
        view.addSubview(pdfView)
        view.addSubview(sheetView)
        sheetView.addSubview(borderView)
        borderView.addSubview(blueView)
        blueView.addSubview(lightImage)
        blueView.addSubview(lightLabel)
        sheetView.addSubview(quailityLabel)
        sheetView.addSubview(percentLabel)
        sheetView.addSubview(compressButton)
        sheetView.addSubview(qualitySlider)
        view.addSubview(loaderView)

        backButton.snp.makeConstraints({
            $0.size.equalTo(38)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(15)
        })

        titleLabel.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(19)
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().inset(60)
        })

        sizeLabel.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().inset(60)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        })

        pdfView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(sizeLabel.snp.bottom).offset(28)
            $0.bottom.equalToSuperview()
        })

        sheetView.snp.makeConstraints({
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(300)
        })

        borderView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(28)
            $0.height.equalTo(60)
        })

        blueView.snp.makeConstraints({
            $0.top.leading.equalToSuperview().offset(2)
            $0.bottom.trailing.equalToSuperview().inset(2)
        })

        lightImage.snp.makeConstraints({
            $0.size.equalTo(35)
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        })

        lightLabel.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(lightImage.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(20)
        })

        quailityLabel.snp.makeConstraints({
            $0.top.equalTo(borderView.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
        })

        percentLabel.snp.makeConstraints({
            $0.top.equalTo(borderView.snp.bottom).offset(18)
            $0.trailing.equalToSuperview().inset(20)
        })

        compressButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(66)
            $0.bottom.equalToSuperview().inset(phoneSize == .big ? 40 : 50)
        })

        qualitySlider.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(quailityLabel.snp.bottom).offset(6)
            $0.height.equalTo(40)
        })

        loaderView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
    }
}
