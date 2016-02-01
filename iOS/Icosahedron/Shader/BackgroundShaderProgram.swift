import GLKit
import OpenGLES

class BackgroundShaderProgram: ShaderProgram {
    enum Uniform: Int {
        case ProjectionMatrix
        case WorldMatrix
        case NormalMatrix
        case Texture
        case Time

        static var count: Int {
            return [ProjectionMatrix, WorldMatrix, NormalMatrix, Texture, Time].count
        }
    }

    var projectionMatrix: GLKMatrix4 = GLKMatrix4Identity {
        didSet {
            withUnsafePointer(&projectionMatrix, {
                glUniformMatrix4fv(uniforms[Uniform.ProjectionMatrix.rawValue], 1, 0, UnsafePointer($0))
            })
        }
    }

    var worldMatrix: GLKMatrix4 = GLKMatrix4Identity {
        didSet {
            withUnsafePointer(&worldMatrix, {
                glUniformMatrix4fv(uniforms[Uniform.WorldMatrix.rawValue], 1, 0, UnsafePointer($0))
            })
        }
    }

    var normalMatrix: GLKMatrix3 = GLKMatrix3Identity {
        didSet {
            withUnsafePointer(&normalMatrix, {
                glUniformMatrix3fv(uniforms[Uniform.NormalMatrix.rawValue], 1, 0, UnsafePointer($0))
            })
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
        super.init(shaderName: "BackgroundShader")

        uniforms = [GLint](count: Uniform.count, repeatedValue: 0)
        uniforms[Uniform.ProjectionMatrix.rawValue] = glGetUniformLocation(programID, "uProjectionMatrix")
        uniforms[Uniform.WorldMatrix.rawValue] = glGetUniformLocation(programID, "uWorldMatrix")
        uniforms[Uniform.NormalMatrix.rawValue] = glGetUniformLocation(programID, "uNormalMatrix")
        uniforms[Uniform.Texture.rawValue] = glGetUniformLocation(programID, "uTexture")
        uniforms[Uniform.Time.rawValue] = glGetUniformLocation(programID, "uTime")
    }
}
