import OpenGLES
import GLKit

func createFaceNormal(x: GLKVector3, y: GLKVector3, z: GLKVector3) -> GLKVector3 {
    return GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(x, y), GLKVector3Subtract(y, z)))
}

protocol Renderable {
    var position: GLKVector3 { get }
    var quaternion: GLKQuaternion { get }
    var localModelVertices: [ModelVertex] { get }
}

extension Renderable {
    var modelVertices: [ModelVertex] {
        let quaternionMatrix = GLKMatrix4MakeWithQuaternion(quaternion)
        return localModelVertices.map { $0.multiplyMatrix4(quaternionMatrix).addVector3(position) }
    }
}