import UIKit

final class ReorderCell: PDF100CollectionCell {
    // MARK: - properties

    // MARK: - views

    private let borderView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .settBanner
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.isHidden = true
        return imageView
    }()

    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .popWhite
        return view
    }()

    private lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()

    private let dotView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 13
        imageView.layer.borderColor = UIColor.subtitle.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()

    // MARK: - overrides

    override class var size: CGSize {
        var width: CGFloat = 0
        if phoneSize == .big {
            width = (deviceWidth - 54)/2
        } else {
            width = (deviceWidth - 42)/2
        }
        let height: CGFloat = phoneSize == .big ? 234 : 224
        return CGSize(
            width: width,
            height: height
        )
    }

    override func setup() {
        super.setup()

        backgroundColor = .clear

        // MARK: - Add Subviews
        addSubview(borderView)
        addSubview(backView)
        addSubview(cellImageView)
        addSubview(dotView)

        // MARK: - Add Constraints
        setupConstraints()
    }

    // MARK: - methods

    func configCell(_ data: ReorderCellModel) {
        cellImageView.image = data.icon
        setSelect(data.isSelect)
    }

    func setSelect(_ isSelect: Bool) {
        dotView.image = isSelect ? .reorderSelect : nil
        borderView.isHidden = !isSelect
    }
}

// MARK: - sizes extensions

extension ReorderCell {

    func setupConstraints() {

        borderView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        backView.snp.makeConstraints({
            $0.top.leading.equalToSuperview().offset(2)
            $0.bottom.trailing.equalToSuperview().inset(2)
        })

        cellImageView.snp.makeConstraints({
            $0.top.leading.equalToSuperview().offset(2)
            $0.bottom.trailing.equalToSuperview().inset(2)
        })

        dotView.snp.makeConstraints({
            $0.size.equalTo(26)
            $0.trailing.equalToSuperview().inset(14)
            $0.top.equalToSuperview().offset(14)
        })
    }
}
