import UIKit

extension UIImage {
    func rotated(byDegrees degrees: CGFloat) -> UIImage? {
        // Calculate radians from degrees
        let radians = degrees * (.pi / 180.0)

        // Get the image size
        let cgImage = self.cgImage
        let width = CGFloat(cgImage!.width)
        let height = CGFloat(cgImage!.height)

        // Determine the new bounds after rotation
        var newSize = CGSize.zero
        newSize.width = abs(height * sin(radians)) + abs(width * cos(radians))
        newSize.height = abs(height * cos(radians)) + abs(width * sin(radians))

        // Begin a new graphics context
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        // Retrieve the current context
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        // Translate and rotate the coordinate system
        ctx.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        ctx.rotate(by: radians)

        // Adjust for proper orientation
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.draw(self.cgImage!, in: CGRect(x: -(width / 2), y: -(height / 2), width: width, height: height))

        // Return the final image
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
