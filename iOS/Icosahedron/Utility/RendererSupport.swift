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
    func modelColor() -> GLKVector4 {
        switch self {
        case .Red:
            return UIColor.flatRedColor().glColor
        case .Green:
            return UIColor.flatGreenColor().glColor
        case .Blue:
            return UIColor.flatBlueColor().glColor
        }
    }

    static func randomColor() -> GLKVector4 {
        let colors = [
            UIColor.flatRedColor().glColor,
            UIColor.flatGreenColor().glColor,
            UIColor.flatBlueColor().glColor,
        ]
        let needle = Int(arc4random_uniform(UInt32(colors.count)))
        return colors[needle]
    }
}
