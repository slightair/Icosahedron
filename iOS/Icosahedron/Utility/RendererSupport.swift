import GLKit
import OpenGLES
import UIKit

func BUFFER_OFFSET(i: Int) -> UnsafePointer<Void> {
    let p: UnsafePointer<Void> = nil
    return p.advancedBy(i)
}

func quaternionForRotate(from from: GLKVector3, to: GLKVector3) -> GLKQuaternion {
    let normalizedFrom = GLKVector3Normalize(from)
    let normalizedTo = GLKVector3Normalize(to)

    let cosTheta = GLKVector3DotProduct(normalizedFrom, normalizedTo)
    let rotationAxis = GLKVector3CrossProduct(normalizedFrom, normalizedTo)

    if cosTheta < -1 + 0.001 {
        var axis = GLKVector3CrossProduct(GLKVector3Make(0, 0, 1), from)
        if GLKVector3Length(axis) < 0.1 {
            axis = GLKVector3CrossProduct(GLKVector3Make(1, 0, 0), from)
        }
        axis = GLKVector3Normalize(axis)
        return GLKQuaternionMakeWithAngleAndVector3Axis(Float(M_PI), axis)
    }

    let s = sqrtf((1 + cosTheta) * 2)
    let inverse = 1 / s

    return GLKQuaternionMakeWithVector3(GLKVector3MultiplyScalar(rotationAxis, inverse), s * 0.5)
}

struct Screen {
    static var aspect: Float {
        let width = CGRectGetHeight(UIScreen.mainScreen().nativeBounds) // long side
        let height = CGRectGetWidth(UIScreen.mainScreen().nativeBounds) // short side

        return Float(fabs(width / height))
    }
}

extension World.Color {
    static func hueForColor(color: World.Color) -> CGFloat {
        switch color {
        case .Red:
            return 0.0
        case .Green:
            return 0.4
        case .Blue:
            return 0.6
        }
    }

    func modelColor(alpha: CGFloat = 1.0) -> GLKVector4 {
        let hue: CGFloat = World.Color.hueForColor(self)
        return UIColor(hue: hue, saturation: 0.6, brightness: 0.85, alpha: alpha).glColor
    }

    func faceColor(alpha: CGFloat = 1.0) -> GLKVector4 {
        let hue: CGFloat = World.Color.hueForColor(self)
        return UIColor(hue: hue, saturation: 0.24, brightness: 1.0, alpha: alpha).glColor
    }
}
