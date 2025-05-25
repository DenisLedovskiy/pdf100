import UIKit

final class Convert: BaseSheetViewController {

    var didImgTap: EmptyBlock?
    var didDocTap: EmptyBlock?

    private lazy var sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .popWhite
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.close, for: .normal)
        button.setImage(.close, for: .highlighted)
        button.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .hellix(.bold, size: 18)
        label.textColor = .textBlack
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("Convert to")
        return label
    }()

    private lazy var imageBtu: ConvertBtn = {
        let button = ConvertBtn()
        button.setupView(title: trans("IMG to PDF"), image: .convertImg)
        button.didTap = {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.close()
            self.didImgTap?()
        }
        return button
    }()

    private lazy var docBtu: ConvertBtn = {
        let button = ConvertBtn()
        button.setupView(title: trans("Word to PDF"), image: .convetrDoc)
        button.didTap = {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.close()
            self.didDocTap?()
        }
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
private extension Convert {

    @objc func tapBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        close()
    }

    func close() {
        dismiss(animated: true)
    }
}


//MARK: - UI
private extension Convert {

    func congifureConstraits() {
        view.addSubview(sheetView)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(backButton)
        sheetView.addSubview(imageBtu)
        sheetView.addSubview(docBtu)

        sheetView.snp.makeConstraints({
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(250)
        })

        titleLabel.snp.makeConstraints({
            $0.top.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().inset(60)
            $0.leading.equalToSuperview().offset(22)
        })

        backButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().inset(22)
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.size.equalTo(32)
        })

        imageBtu.snp.makeConstraints({
            $0.top.equalToSuperview().offset(64)
            $0.leading.equalToSuperview().offset(22)
            $0.height.equalTo(98)
            $0.trailing.equalTo(view.snp.centerX).offset(-7)
        })

        docBtu.snp.makeConstraints({
            $0.top.equalToSuperview().offset(64)
            $0.trailing.equalToSuperview().inset(22)
            $0.height.equalTo(98)
            $0.leading.equalTo(view.snp.centerX).offset(7)
        })
    }
}
