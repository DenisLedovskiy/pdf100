import PanModal
import UIKit

final class ChangeIcon: BaseSheetViewController {

    let iconsize: CGFloat = switch phoneSize {
    case .big: 185
    case .medium: 165
    case .small: 150
    }

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
        label.font = .hellix(.bold, size: 25)
        label.textColor = .textBlack
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.text = trans("Change icon")
        return label
    }()

    private let icon1View: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .icon0
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 22
        return imageView
    }()

    private lazy var icon1Button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(tapIcon1), for: .touchUpInside)
        return button
    }()

    private lazy var icon2Button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(tapIcon2), for: .touchUpInside)
        return button
    }()

    private let icon2View: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .icon1
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 22
        return imageView
    }()

    private let borderView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .settBanner
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 24
        return imageView
    }()

    private let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .popWhite
        view.layer.cornerRadius = 22
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        view.layer.masksToBounds = false
        return view
    }()


    //MARK: -  Lifecicle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //    MARK: - Ovverides
    override func setup() {
        congifureConstraits()
        setStartSelect()
    }

}
//MARK: - Private
private extension ChangeIcon {

    @objc func tapBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        close()
    }

    func close() {
        dismiss(animated: true)
    }

    @objc func tapIcon1() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        borderView.snp.remakeConstraints({
            $0.size.equalTo(iconsize + 12)
            $0.center.equalTo(icon1View)
        })

        shadowView.snp.remakeConstraints({
            $0.size.equalTo(iconsize)
            $0.center.equalTo(icon2View)
        })

        UserDefSettings.isFirstIconSet = true

        UIApplication.shared.setAlternateIconName(nil)
    }

    @objc func tapIcon2() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        borderView.snp.remakeConstraints({
            $0.size.equalTo(iconsize + 12)
            $0.center.equalTo(icon2View)
        })

        shadowView.snp.remakeConstraints({
            $0.size.equalTo(iconsize)
            $0.center.equalTo(icon1View)
        })

        UserDefSettings.isFirstIconSet = false

        UIApplication.shared.setAlternateIconName("AppIcon2") { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}


//MARK: - UI
private extension ChangeIcon {

    func setStartSelect() {
        if UserDefSettings.isFirstIconSet ?? true {
            borderView.snp.remakeConstraints({
                $0.size.equalTo(iconsize + 12)
                $0.center.equalTo(icon1View)
            })

            shadowView.snp.remakeConstraints({
                $0.size.equalTo(iconsize)
                $0.center.equalTo(icon2View)
            })
        } else {
            borderView.snp.remakeConstraints({
                $0.size.equalTo(iconsize + 12)
                $0.center.equalTo(icon2View)
            })

            shadowView.snp.remakeConstraints({
                $0.size.equalTo(iconsize)
                $0.center.equalTo(icon1View)
            })
        }
    }

    func congifureConstraits() {
        view.addSubview(sheetView)
        sheetView.addSubview(borderView)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(backButton)
        sheetView.addSubview(shadowView)
        sheetView.addSubview(icon1View)
        sheetView.addSubview(icon1Button)
        sheetView.addSubview(icon2View)
        sheetView.addSubview(icon2Button)

        sheetView.snp.makeConstraints({
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(330)
        })

        titleLabel.snp.makeConstraints({
            $0.top.equalToSuperview().offset(33)
            $0.trailing.equalToSuperview().inset(60)
            $0.leading.equalToSuperview().offset(23)
        })

        backButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.size.equalTo(34)
        })

        icon1View.snp.makeConstraints({
            $0.size.equalTo(iconsize)
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(22)
        })

        icon1Button.snp.makeConstraints({
            $0.size.equalTo(iconsize)
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(22)
        })

        icon2View.snp.makeConstraints({
            $0.size.equalTo(iconsize)
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.trailing.equalToSuperview().inset(22)
        })

        icon2Button.snp.makeConstraints({
            $0.size.equalTo(iconsize)
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.trailing.equalToSuperview().inset(22)
        })

        borderView.snp.remakeConstraints({
            $0.size.equalTo(iconsize + 12)
            $0.center.equalTo(icon1View)
        })

        shadowView.snp.makeConstraints({
            $0.size.equalTo(iconsize)
            $0.center.equalTo(icon2View)
        })
    }
}
