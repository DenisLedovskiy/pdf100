import UIKit

extension UIImage {
    func rotated(byDegrees degrees: CGFloat) -> UIImage? {
        let radians = degrees * (.pi / 180.0)
        let cgImage = self.cgImage
        let width = CGFloat(cgImage!.width)
        let height = CGFloat(cgImage!.height)

        var newSize = CGSize.zero
        newSize.width = abs(height * sin(radians)) + abs(width * cos(radians))
        newSize.height = abs(height * cos(radians)) + abs(width * sin(radians))

        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        ctx.rotate(by: radians)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.draw(self.cgImage!, in: CGRect(x: -(width / 2), y: -(height / 2), width: width, height: height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
