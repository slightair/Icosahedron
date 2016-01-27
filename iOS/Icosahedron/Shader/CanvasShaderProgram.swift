import GLKit
import OpenGLES

class CanvasShaderProgram: ShaderProgram {
    enum Uniform: Int {
        case Texture

        static var count: Int {
            return [Texture].count
        }
    }

    var texture: GLint = 0 {
        didSet {
            glUniform1i(uniforms[Uniform.Texture.rawValue], texture)
        }
    }

    init() {
        super.init(shaderName: "CanvasShader")

        uniforms = [GLint](count: Uniform.count, repeatedValue: 0)
        uniforms[Uniform.Texture.rawValue] = glGetUniformLocation(programID, "uTexture")
    }
}
