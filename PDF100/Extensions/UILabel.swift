import UIKit

extension UILabel {
    func setLetterSpace(_ space: Double) {
        guard let text = self.text else { return }
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.kern, value: 1.0, range: NSRange(location: 0, length: attributedText.length))
        self.attributedText = attributedText
    }
}
