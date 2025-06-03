import UIKit
import Lottie

final class CompressLoaderView: UIView {

    // MARK: - properties

    // MARK: - views

    private lazy var blur: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.3)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = .hellix(.bold, size: 22)
        label.text = trans("Compressing") + "..."
        return label
    }()

    private lazy var animation: LottieAnimationView = {
        let animation = LottieAnimationView(name: "pdf100")
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        return animation
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        backgroundColor = .clear
        addSubview(blur)
        addSubview(overlayView)
        addSubview(titleLabel)
        addSubview(animation)
        setupConstraits()
    }

    func startIndicator(_ isNeedStart: Bool) {
        isNeedStart ? animation.play() : animation.stop()
    }

}

private extension CompressLoaderView {

    func setupConstraits() {
        blur.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        overlayView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        animation.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.snp.centerY).offset(70)
            $0.height.equalTo(260)
            $0.width.equalTo(240)
        })

        titleLabel.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.snp.centerY).offset(50)
        })


    }
}


