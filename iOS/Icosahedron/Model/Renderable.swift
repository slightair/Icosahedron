import OpenGLES
import GLKit

func createFaceNormal(x: GLKVector3, y: GLKVector3, z: GLKVector3) -> GLKVector3 {
    return GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(x, y), GLKVector3Subtract(y, z)))
}

protocol Renderable {
    var position: GLKVector3 { get }
    var quaternion: GLKQuaternion { get }
    var localModelVertices: [ModelVertex] { get }
    var scale: GLKVector3 { get }
    var customColor: GLKVector4? { get }
}

extension Renderable {
    var scale: GLKVector3 {
        return GLKVector3Make(1.0, 1.0, 1.0)
    }

    var customColor: GLKVector4? {
        return nil
    }

    var modelVertices: [ModelVertex] {
        let quaternionMatrix = GLKMatrix4MakeWithQuaternion(quaternion)
        let matrix = GLKMatrix4ScaleWithVector3(quaternionMatrix, scale)
        return localModelVertices.map { vertex in
            var convertedVertex = vertex.multiplyMatrix4(matrix).addVector3(position)
            if let newColor = customColor {
                convertedVertex = convertedVertex.changeColor(newColor)
            }
            return convertedVertex
        }
    }
}

enum RenderableHorizontalAlign {
    case Left, Center, Right
}

enum RenderableVerticalAlign {
    case Top, Center, Bottom
}

enum RenderableDirection {
    case LeftToRight, RightToLeft
}
