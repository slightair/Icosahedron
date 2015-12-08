import GLKit
import OpenGLES

class ModelShaderProgram: ShaderProgram {
    enum Uniform: Int {
        case ProjectionMatrix
        case WorldMatrix
        case NormalMatrix
        case Texture

        static var count: Int {
            return [ProjectionMatrix, WorldMatrix, NormalMatrix, Texture].count
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

    var texture: GLint = 0 {
        didSet {
            glUniform1i(uniforms[Uniform.Texture.rawValue], texture)
        }
    }

    init() {
        super.init(shaderName: "ModelShader")

        uniforms = [GLint](count: Uniform.count, repeatedValue: 0)
        uniforms[Uniform.ProjectionMatrix.rawValue] = glGetUniformLocation(programID, "uProjectionMatrix")
        uniforms[Uniform.WorldMatrix.rawValue] = glGetUniformLocation(programID, "uWorldMatrix")
        uniforms[Uniform.NormalMatrix.rawValue] = glGetUniformLocation(programID, "uNormalMatrix")
        uniforms[Uniform.Texture.rawValue] = glGetUniformLocation(programID, "uTexture")
    }
}
