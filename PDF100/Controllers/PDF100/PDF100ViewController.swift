import UIKit

class PDF100ViewController: UIViewController {

    private var activityView: UIView?

    var selectedPrinter: UIPrinter?

    var tabBar: AppTabBar? {
        return self.tabBarController as? AppTabBar
    }

    var back: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = .controllerGradient
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addBack()
    }
}

//MARK: - back

extension PDF100ViewController {

    func addBack() {
        view.addSubview(back)
        back.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
    }
}

//MARK: - Spiner

extension PDF100ViewController {
    func startSpinner() {
        activityView = UIView(frame: self.view.bounds)
        activityView?.backgroundColor = .black.withAlphaComponent(0.2)

        guard let activityView = activityView else {return}
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = activityView.center
        activityIndicator.startAnimating()
        activityView.addSubview(activityIndicator)
        self.view.addSubview(activityView)
    }

    func endSpinner() {
        DispatchQueue.main.async {
            self.activityView?.removeFromSuperview()
            self.activityView = nil
        }
    }
}

//MARK: - Alert

extension PDF100ViewController {

    func showErrorAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func showErrorSettingAlert(title: String, message: String) {

        DispatchQueue.main.async {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: perevod("Settings"), style: UIAlertAction.Style.default, handler: { [weak self] _ in
//                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                self?.openSettings()
//            }))
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//
//            DispatchQueue.main.async {
//                self.present(alert, animated: true, completion: nil)
//            }
        }
    }

    func openSettings() {
        guard let settings = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settings) else {
            return
        }

        if UIApplication.shared.canOpenURL(settings) {
            UIApplication.shared.open(settings)
        }
    }
}

//MARK: - Tab and Nav bars
extension PDF100ViewController {
    func hideTabBar(_ isHide: Bool) {
        tabBar?.hideTabBar(isHide)
    }

    func hideNavBar(_ isHide: Bool) {
        navigationController?.navigationBar.isHidden = isHide
    }
}

//MARK: - Collection

extension PDF100ViewController {
    func setTableLayout(size: CGSize,
                        interGroupSpace: CGFloat = 15,
                        leftRightInset: CGFloat = 20,
                        topInset: CGFloat = 0) -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(size.width),
                                              heightDimension: .absolute(size.height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, repeatingSubitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = interGroupSpace
        section.contentInsets = .init(top: topInset,
                                      leading: leftRightInset,
                                      bottom: 150,
                                      trailing: leftRightInset)
        return section
    }

    func setGridLayout(size: CGSize,
                        interItemSpace: CGFloat = 14,
                        interGroupSpace: CGFloat = 14,
                        countItems: Int,
                        leftRightInset: CGFloat = 16,
                        bottomInset: CGFloat = 20,
                        topInset: CGFloat = 0) -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(size.width),
                                              heightDimension: .absolute(size.height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(size.height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       repeatingSubitem: item,
                                                       count: countItems)
        group.interItemSpacing = .fixed(interItemSpace)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = interGroupSpace
        section.contentInsets = .init(top: topInset,
                                      leading: leftRightInset,
                                      bottom: bottomInset,
                                      trailing: leftRightInset)
        return section
    }
}
