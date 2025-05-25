import UIKit

class SearchView: UIView {

    var didChangeWord: ((String)->())?

    // MARK: - properties

    // MARK: - views

    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .textSearch
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.image = .search
        return imageView
    }()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = trans("Search")
        textField.tintColor = .textBlack
        textField.addTarget(self, action: #selector(changeText), for: .editingChanged)
        return textField
    }()

    private lazy var clearBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(.clear, for: .normal)
        button.setImage(.clear, for: .highlighted)
        button.addTarget(self, action: #selector(tapClear), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var wordLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.text = "0 \(trans("of")) 0"
        label.textColor = .subtitle
        label.font = .hellix(.semibold, size: 16)
        return label
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
        addSubview(backView)
        backView.addSubview(textField)
        backView.addSubview(clearBtn)
        backView.addSubview(searchIcon)
        addSubview(wordLabel)
        setupConstraits()
    }

    func setWord(current: Int, all: Int) {
        wordLabel.text = "\(current) \(trans("of")) \(all)"
    }

    func clearAll() {
        textField.text = ""
        clearBtn.isHidden = true
    }
}

private extension SearchView {

    @objc func tapClear() {
        textField.text = ""
        clearBtn.isHidden = true
        didChangeWord?("")
    }

    @objc func changeText() {
        if textField.text?.count ?? 0 > 0 {
            clearBtn.isHidden = false
        } else {
            clearBtn.isHidden = true
        }
        didChangeWord?(textField.text ?? "")
    }

    func setupConstraits() {

        wordLabel.snp.makeConstraints({
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        })

        backView.snp.makeConstraints({
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(78)
        })

        searchIcon.snp.makeConstraints({
            $0.size.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
        })

        textField.snp.makeConstraints({
            $0.leading.equalTo(searchIcon.snp.trailing).offset(6)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(40)
        })

        clearBtn.snp.makeConstraints({
            $0.size.equalTo(25)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
        })
    }
}
