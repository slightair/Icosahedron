import OpenGLES
import GLKit

protocol Renderable {
    var modelViewMatrix: GLKMatrix4 { get set }
    var quaternion: GLKQuaternion { get set }

    func prepare()
    func render(program: ModelShaderProgram)
}
