import UIKit

final class HomeCell: PDF100CollectionCell {
    // MARK: - properties

    private let cornerRadius: CGFloat = 20

    // MARK: - views

    private lazy var pdfImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .hellix(.semibold, size: 20)
        label.textColor = .textBlack
        label.textAlignment = .natural
        label.numberOfLines = 1
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .hellix(.semibold, size: 16)
        label.textColor = .subtitle
        label.textAlignment = .natural
        label.numberOfLines = 1
        return label
    }()

    private lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = .hellix(.semibold, size: 16)
        label.textColor = .subtitle
        label.textAlignment = .natural
        label.numberOfLines = 1
        return label
    }()


    private let dotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.image = .dots
        return imageView
    }()

    // MARK: - overrides

    override class var size: CGSize {
        let width: CGFloat = deviceWidth - 40
        let height: CGFloat = 84
        return CGSize(
            width: width,
            height: height
        )
    }

    override func setup() {
        super.setup()

        backgroundColor = .white
        layer.cornerRadius = cornerRadius

        layer.shadowRadius = 16
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.black.withAlphaComponent(0.04).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        clipsToBounds = false

        // MARK: - Add Subviews
        addSubview(pdfImageView)
        addSubview(titleLabel)
        addSubview(dateLabel)
        addSubview(dotImageView)
        addSubview(sizeLabel)

        // MARK: - Add Constraints
        setupConstraints()
    }

    // MARK: - methods

    func configCell(_ data: HomeCellModel) {
        titleLabel.text =  data.title + ".pdf"
        dateLabel.text = formatDateToString(date: data.date)
        pdfImageView.image = data.icon
        sizeLabel.text = data.size
    }

}

// MARK: - sizes extensions

extension HomeCell {

    func setupConstraints() {

        pdfImageView.snp.makeConstraints({
            $0.top.bottom.equalToSuperview().inset(14)
            $0.leading.equalToSuperview().offset(22)
            $0.width.equalTo(52)
        })

        titleLabel.snp.makeConstraints({
            $0.leading.equalTo(pdfImageView.snp.trailing).offset(25)
            $0.trailing.equalToSuperview().inset(40)
            $0.top.equalToSuperview().offset(20)
        })

        dateLabel.snp.makeConstraints({
            $0.leading.equalTo(pdfImageView.snp.trailing).offset(25)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        })

        dotImageView.snp.makeConstraints({
            $0.height.equalTo(20)
            $0.width.equalTo(23)
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().inset(15)
        })

        sizeLabel.snp.makeConstraints({
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(23)
        })
    }

    func formatDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
}
