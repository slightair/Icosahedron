import GLKit
import OpenGLES

class CanvasShaderProgram: ShaderProgram {
    enum Uniform: Int {
        case Texture
        case BlockSize
        case NoiseFactor
        case Time

        static var count: Int {
            return [Texture, BlockSize, NoiseFactor, Time].count
        }
    }

    var blockSize: GLKVector2 = GLKVector2Make(1, 1) {
        didSet {
            withUnsafePointer(&blockSize, {
                glUniform2fv(uniforms[Uniform.BlockSize.rawValue], 1, UnsafePointer($0))
            })
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

    override class func bindAttribLocation(program: GLuint) {
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.Position.rawValue), "position")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.Color.rawValue), "color")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.TexCoord0.rawValue), "texCoord")
    }

    init() {
        super.init(shaderName: "CanvasShader")

        uniforms = [GLint](count: Uniform.count, repeatedValue: 0)
        uniforms[Uniform.Texture.rawValue] = glGetUniformLocation(programID, "uTexture")
        uniforms[Uniform.BlockSize.rawValue] = glGetUniformLocation(programID, "uBlockSize")
        uniforms[Uniform.NoiseFactor.rawValue] = glGetUniformLocation(programID, "uNoiseFactor")
        uniforms[Uniform.Time.rawValue] = glGetUniformLocation(programID, "uTime")
    }
}
