import UIKit

class CustomSlider: UISlider {

    private let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSlider()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSlider()
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 12
        return newBounds
    }

    private func setupSlider() {
        self.setThumbImage(UIImage(), for: .normal)
        thumbImageView.image = UIImage(named: "sliderPimp")
        thumbImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        thumbImageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        thumbImageView.layer.shadowOpacity = 1
        thumbImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        thumbImageView.layer.shadowRadius = 5
        self.addSubview(thumbImageView)
        updateThumbPosition(value: self.value)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateThumbPosition(value: self.value)
    }

    private func updateThumbPosition(value: Float) {
        let thumbWidth = thumbImageView.frame.width
        let thumbHeight = thumbImageView.frame.height
        let sliderWidth = self.bounds.width - thumbWidth
        let percentage = CGFloat(value - self.minimumValue) / CGFloat(self.maximumValue - self.minimumValue)
        let thumbX = percentage * sliderWidth
        let thumbY = ((self.bounds.height - thumbHeight) / 2) + 3
        thumbImageView.frame = CGRect(x: thumbX, y: thumbY, width: thumbWidth, height: thumbHeight)
    }
}
