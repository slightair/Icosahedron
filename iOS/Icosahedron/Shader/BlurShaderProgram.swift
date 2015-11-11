import GLKit
import OpenGLES

class BlurShaderProgram : ShaderProgram {
    enum Uniform: Int {
        case SourceTexture
        case TexelSize
        case UseBlur

        static var count: Int {
            return [SourceTexture, TexelSize, UseBlur].count
        }
    }

    var sourceTexture: GLint = 0 {
        didSet {
            glUniform1i(uniforms[Uniform.SourceTexture.rawValue], sourceTexture)
        }
    }

    var texelSize: GLKVector2 = GLKVector2Make(0, 0) {
        didSet {
            withUnsafePointer(&texelSize, {
                glUniform2fv(uniforms[Uniform.TexelSize.rawValue], 1, UnsafePointer($0))
            })
        }
    }

    var useBlur: Bool = false {
        didSet {
            let boolParam = useBlur ? GLint(GL_TRUE) : GLint(GL_FALSE)
            glUniform1i(uniforms[Uniform.UseBlur.rawValue], boolParam)
        }
    }

    init() {
        super.init(shaderName: "BlurShader")

        uniforms = [GLint](count: Uniform.count, repeatedValue: 0)
        uniforms[Uniform.SourceTexture.rawValue] = glGetUniformLocation(programID, "sourceTexture")
        uniforms[Uniform.TexelSize.rawValue] = glGetUniformLocation(programID, "texelSize")
        uniforms[Uniform.UseBlur.rawValue] = glGetUniformLocation(programID, "useBlur")
    }
}
