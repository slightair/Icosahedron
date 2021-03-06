import GLKit
import OpenGLES

class ParticleShaderProgram: ShaderProgram {
    static let PointSizeAttribLocation: GLuint = 10

    enum Uniform: Int {
        case ProjectionMatrix
        case WorldMatrix
        case Texture

        static var count: Int {
            return [ProjectionMatrix, WorldMatrix, Texture].count
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

    override class func bindAttribLocation(program: GLuint) {
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.Position.rawValue), "position")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.Color.rawValue), "color")
        glBindAttribLocation(program, ParticleShaderProgram.PointSizeAttribLocation, "pointSize")
    }

    init() {
        super.init(shaderName: "ParticleShader")

        uniforms = [GLint](count: Uniform.count, repeatedValue: 0)
        uniforms[Uniform.ProjectionMatrix.rawValue] = glGetUniformLocation(programID, "uProjectionMatrix")
        uniforms[Uniform.WorldMatrix.rawValue] = glGetUniformLocation(programID, "uWorldMatrix")
        uniforms[Uniform.Texture.rawValue] = glGetUniformLocation(programID, "uTexture")
    }
}
