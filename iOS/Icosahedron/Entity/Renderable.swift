import OpenGLES
import GLKit

func createFaceNormal(x: GLKVector3, y: GLKVector3, z: GLKVector3) -> GLKVector3 {
    return GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(x, y), GLKVector3Subtract(y, z)))
}

protocol Renderable {
    var position: GLKVector3 { get }
    var quaternion: GLKQuaternion { get }
    func prepare()
    func render(program: ModelShaderProgram)
}

extension Renderable {
    var modelMatrix: GLKMatrix4 {
        let quaternionMatrix = GLKMatrix4MakeWithQuaternion(quaternion)
        let translationMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z)

        return GLKMatrix4Multiply(translationMatrix, quaternionMatrix)
    }
}
