import UIKit

class PresentationController: UIPresentationController {

    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    let heightContainerView: Int
    let overlay: UIView!

    init(presentedViewController: UIViewController, presenting: UIViewController?, heightContainerView: Int) {
        let blurEffect = UIBlurEffect(style: .extraLight)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.15)
        overlay = view
        self.heightContainerView = heightContainerView
        super.init(presentedViewController: presentedViewController, presenting: presenting)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.overlay.isUserInteractionEnabled = true
        self.overlay.addGestureRecognizer(tapGestureRecognizer)

    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
                    return CGRect(
                        x: 0.0,
                        y: self.containerView!.frame.height - CGFloat(heightContainerView),
                        width: containerView.bounds.width,
                        height: CGFloat(heightContainerView)
                    )
    }

    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.overlay.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        self.containerView?.addSubview(overlay)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 1.0
            self.overlay.alpha = 1
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }

    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0
            self.overlay.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
            self.overlay.removeFromSuperview()
        })
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.roundCorners([.topLeft, .topRight], radius: 20)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
        self.overlay.frame = containerView!.bounds
    }

    @objc func dismissController(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}


