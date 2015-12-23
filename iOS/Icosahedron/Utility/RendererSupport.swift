import GLKit
import OpenGLES

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
