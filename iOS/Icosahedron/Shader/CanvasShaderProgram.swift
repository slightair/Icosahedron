import GLKit
import OpenGLES

class CanvasShaderProgram: ShaderProgram {
    enum Uniform: Int {
        case Texture
        case NoiseFactor
        case Time

        static var count: Int {
            return [Texture, NoiseFactor, Time].count
        }
    }

    var noiseFactor: GLfloat = 0.0 {
        didSet {
            glUniform1f(uniforms[Uniform.NoiseFactor.rawValue], noiseFactor)
        }
    }

    var time: GLfloat = 0.0 {
        didSet {
            glUniform1f(uniforms[Uniform.Time.rawValue], time)
        }
    }

    init() {
        super.init(shaderName: "CanvasShader")

        uniforms = [GLint](count: Uniform.count, repeatedValue: 0)
        uniforms[Uniform.Texture.rawValue] = glGetUniformLocation(programID, "uTexture")
        uniforms[Uniform.NoiseFactor.rawValue] = glGetUniformLocation(programID, "uNoiseFactor")
        uniforms[Uniform.Time.rawValue] = glGetUniformLocation(programID, "uTime")
    }
}
