import OpenGLES
import GLKit

protocol Renderable {
    var modelMatrix: GLKMatrix4 { get set }

    func prepare()
    func render(program: ModelShaderProgram)
}
