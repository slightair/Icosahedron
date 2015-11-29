import UIKit
import GLKit

extension UIColor {
    var glColor: GLKVector4 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return GLKVector4Make(Float(red), Float(green), Float(blue), Float(alpha))
    }
}
