import OpenGLES
import GLKit

protocol RenderablePolygon {
    var position: GLKVector3 { get }
    var quaternion: GLKQuaternion { get }
    var localModelVertices: [ModelVertex] { get }
    var modelIndexes: [GLushort] { get }
}

extension RenderablePolygon {
    var modelVertices: [ModelVertex] {
        let quaternionMatrix = GLKMatrix4MakeWithQuaternion(quaternion)
        return localModelVertices.map { vertex in
            return vertex.multiplyMatrix4(quaternionMatrix).addVector3(position)
        }
    }
}
