import GLKit
import OpenGLES

class UIShaderProgram: ShaderProgram {
    enum Uniform: Int {
        case ProjectionMatrix
        case Texture

        static var count: Int {
            return [ProjectionMatrix, Texture].count
        }
    }

    var projectionMatrix: GLKMatrix4 = GLKMatrix4Identity {
        didSet {
            withUnsafePointer(&projectionMatrix, {
                glUniformMatrix4fv(uniforms[Uniform.ProjectionMatrix.rawValue], 1, 0, UnsafePointer($0))
            })
        }
    }

    init() {
        super.init(shaderName: "UIShader")

        uniforms = [GLint](count: Uniform.count, repeatedValue: 0)
        uniforms[Uniform.ProjectionMatrix.rawValue] = glGetUniformLocation(programID, "uProjectionMatrix")
        uniforms[Uniform.Texture.rawValue] = glGetUniformLocation(programID, "uTexture")
    }
}
