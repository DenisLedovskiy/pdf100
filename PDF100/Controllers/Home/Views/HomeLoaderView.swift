import UIKit

final class HomeLoaderView: UIView {

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
        label.text = trans("Converting") + "..."
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        return activityIndicator
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
        addSubview(activityIndicator)
        setupConstraits()
    }

    func startIndicator(_ isNeedStart: Bool) {
        isNeedStart ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

}

private extension HomeLoaderView {


    func setupConstraits() {
        blur.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        overlayView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        titleLabel.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.snp.centerY).offset(10)
        })

        activityIndicator.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-20)
        })
    }
}


