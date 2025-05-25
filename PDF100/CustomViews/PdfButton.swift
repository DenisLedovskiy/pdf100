import UIKit

final class PdfButton: UIButton {

    var height: Double {
        return phoneSize == .big ? 76 : 68
    }

    private lazy var backImg: UIImageView = {
        let img = UIImageView()
        img.image = .gradientSample
        img.clipsToBounds = true
        return img
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(backImg)

        backImg.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
    }

    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        backImg.layer.cornerRadius = radius
    }

    func setTitle(_ title: String) {
        let normalAttributedString = NSAttributedString(
            string: title,
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.font : UIFont.hellix(.bold, size: phoneSize == .big ? 22 : 18)
            ]
        )
        setAttributedTitle(normalAttributedString, for: .normal)
        setAttributedTitle(normalAttributedString, for: .highlighted)
    }

    func setActive(_ isActive: Bool) {
        isUserInteractionEnabled = isActive
        alpha = isActive ? 1 : 0.5
    }
}
