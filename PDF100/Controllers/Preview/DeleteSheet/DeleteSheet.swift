import UIKit

final class DeleteSheet: BaseSheetViewController {

    var didTap: EmptyBlock?

    private lazy var sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .popWhite
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.closeGray, for: .normal)
        button.setImage(.closeGray, for: .highlighted)
        button.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
        return button
    }()

    private let bigImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.image = .deleteIcon
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .hellix(.bold, size: 22)
        label.textColor = .textBlack
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("Do you want to exit without saving  your changes?")
        return label
    }()

    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .hellix(.semibold, size: 18)
        label.textColor = .subtitle
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("You will lose all edits")
        return label
    }()

    private lazy var discardButton: PdfButton = {
        let button = PdfButton()
        button.setTitle(trans("Discard"))
        button.addTarget(self, action: #selector(tapDeiscard), for: .touchUpInside)

        button.setCornerRadius(24)

        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        button.layer.shadowColor = UIColor.shadowBlue.withAlphaComponent(0.8).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 9)
        button.clipsToBounds = false
        return button
    }()

    //MARK: -  Lifecicle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        congifureConstraits()
    }

    //    MARK: - Ovverides
    override func setup() {
        congifureConstraits()
    }

}
//MARK: - Private
private extension DeleteSheet {

    @objc func tapBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        close()
    }

    func close() {
        dismiss(animated: true)
    }

    @objc func tapDeiscard() {
        close()
        didTap?()
    }
}


//MARK: - UI
private extension DeleteSheet {

    func congifureConstraits() {
        view.addSubview(sheetView)
        sheetView.addSubview(backButton)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(subTitleLabel)
        sheetView.addSubview(bigImageView)
        sheetView.addSubview(discardButton)

        sheetView.snp.makeConstraints({
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(450)
        })

        backButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(20)
            $0.size.equalTo(32)
        })

        bigImageView.snp.makeConstraints({
            $0.top.equalToSuperview().offset(44)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(136)
        })

        titleLabel.snp.makeConstraints({
            $0.top.equalTo(bigImageView.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(40)
            $0.leading.equalToSuperview().offset(40)
        })

        subTitleLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(40)
            $0.leading.equalToSuperview().offset(40)
        })

        discardButton.snp.makeConstraints({
            $0.bottom.equalToSuperview().inset(60)
            $0.trailing.leading.equalToSuperview().inset(20)
            $0.height.equalTo(66)
        })
    }
}
