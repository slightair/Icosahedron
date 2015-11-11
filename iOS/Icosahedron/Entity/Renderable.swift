import OpenGLES
import GLKit

protocol Renderable {
    var quaternion: GLKQuaternion { get }

    func prepare()
    func render(program: ModelShaderProgram)
}

extension Renderable {
    var modelViewMatrix: GLKMatrix4 {
        let baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -1.0)
        let quaternionMatrix = GLKMatrix4MakeWithQuaternion(quaternion)

        return GLKMatrix4Multiply(baseModelViewMatrix, quaternionMatrix)
    }
}
