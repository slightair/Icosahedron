import OpenGLES
import GLKit

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
