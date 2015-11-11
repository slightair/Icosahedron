import GLKit
import OpenGLES

class ModelShaderProgram : ShaderProgram {
    enum Uniform: Int {
        case ProjectionMatrix
        case ModelViewMatrix
        case NormalMatrix
        case VertexTexture
        case UseTexture

        static var count: Int {
            return [ProjectionMatrix, ModelViewMatrix, NormalMatrix, VertexTexture, UseTexture].count
        }
    }

    var projectionMatrix: GLKMatrix4 = GLKMatrix4Identity {
        didSet {
            withUnsafePointer(&projectionMatrix, {
                glUniformMatrix4fv(uniforms[Uniform.ProjectionMatrix.rawValue], 1, 0, UnsafePointer($0))
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

    var modelViewMatrix: GLKMatrix4 = GLKMatrix4Identity {
        didSet {
            withUnsafePointer(&modelViewMatrix, {
                glUniformMatrix4fv(uniforms[Uniform.ModelViewMatrix.rawValue], 1, 0, UnsafePointer($0))
            })
        }
    }

    var vertexTexture: GLint = 0 {
        didSet {
            glUniform1i(uniforms[Uniform.VertexTexture.rawValue], 0)
        }
    }

    var useTexture: Bool = false {
        didSet {
            let boolParam = useTexture ? GLint(GL_TRUE) : GLint(GL_FALSE)
            glUniform1i(uniforms[Uniform.UseTexture.rawValue], boolParam)
        }
    }

    init() {
        super.init(shaderName: "ModelShader")

        uniforms = [GLint](count: Uniform.count, repeatedValue: 0)
        uniforms[Uniform.ProjectionMatrix.rawValue] = glGetUniformLocation(programID, "projectionMatrix")
        uniforms[Uniform.NormalMatrix.rawValue] = glGetUniformLocation(programID, "normalMatrix")
        uniforms[Uniform.ModelViewMatrix.rawValue] = glGetUniformLocation(programID, "modelViewMatrix")
        uniforms[Uniform.VertexTexture.rawValue] = glGetUniformLocation(programID, "vertexTexture")
        uniforms[Uniform.UseTexture.rawValue] = glGetUniformLocation(programID, "useTexture")
    }
}
