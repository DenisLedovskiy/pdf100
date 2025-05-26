import PDFKit
import UIKit

final class Compress: PDF100ViewController {

    private let tempName = "pdf-word-temp.pdf"

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
        label.text = trans("By increasing the quality, you increase the file size")
        label.textColor = .textBlack
        label.font = .hellix(.semibold, size: 16)
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
        button.setTitle(trans("Compress file"))
        button.addTarget(self, action: #selector(tapCompress), for: .touchUpInside)

        button.setCornerRadius(24)

        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        button.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 9)
        button.clipsToBounds = false
        return button
    }()

    private lazy var thinkSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 30
        slider.minimumTrackTintColor = UIColor(patternImage: .gradientSample)
        slider.maximumTrackTintColor = .sliderGray
        let thumbImage = createThumbImage(imageNamed: "sliderPimp", shadowOffset: CGSize(width: 0, height: 2), shadowBlurRadius: 3)
        slider.setThumbImage(thumbImage, for: .normal)

//        slider.setThumbImage(.sliderPimp, for: .normal)
        slider.addTarget(self, action: #selector(sliderChange(slider:event:)), for: .valueChanged)

        slider.layer.masksToBounds = false
        return slider
    }()

    private func createThumbImage(imageNamed: String, shadowOffset: CGSize, shadowBlurRadius: CGFloat) -> UIImage? {
        guard let thumbIcon = UIImage(named: imageNamed)?.withRenderingMode(.alwaysOriginal) else { return nil }

        // Create a transparent background image
        let size = thumbIcon.size
        let renderer = UIGraphicsImageRenderer(size: size)

        let thumbImage = renderer.image { context in
            // Apply shadow properties
            context.cgContext.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: UIColor.black.withAlphaComponent(0.1).cgColor)

            // Draw the thumb icon
            thumbIcon.draw(at: CGPoint(x: 0, y: 0))
        }

        return thumbImage.withRenderingMode(.alwaysOriginal)
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

        setPDF()
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
            case .ended: return
            default:
                break
            }
        }
    }
}

//MARK: - UI
private extension Compress {

    func setPDF() {
        if let pdfURL = Bundle.main.url(forResource: "samplePDF", withExtension: "pdf") {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            if let destinationPath = documentsDirectory?.appendingPathComponent(tempName) {
                try? FileManager.default.removeItem(at: destinationPath)
                try? FileManager.default.copyItem(at: pdfURL, to: destinationPath)
            }
        }
        updatePDF()
    }

    func updatePDF() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = tempName
        if let fileURL = documentsDirectory?.appendingPathComponent(fileName) {
            let newPdfDoc = PDFDocument(url: fileURL)
            pdfView.document = newPdfDoc
        }

        sizeLabel.text = humanReadableSize(from: tempName)
    }

    func humanReadableSize(from docName: String) -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = docName
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
        sheetView.addSubview(thinkSlider)

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
            $0.bottom.equalToSuperview().inset(50)
        })

        thinkSlider.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(quailityLabel.snp.bottom).offset(6)
            $0.height.equalTo(40)
        })
    }
}
