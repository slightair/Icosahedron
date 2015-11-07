import GLKit
import OpenGLES
import SpriteKit

func BUFFER_OFFSET(i: Int) -> UnsafePointer<Void> {
    let p: UnsafePointer<Void> = nil
    return p.advancedBy(i)
}

class GameViewController: GLKViewController {
    enum Program: GLuint {
        case Model
        case Blur
    }

    enum ModelShaderUniform: GLuint {
        case ModelViewProjectionMatrix
        case NormalMatrix
        case VertexTexture
        case UseTexture
    }

    enum BlurShaderUniform: GLuint {
        case SourceTexture
        case TexelSize
        case UseBlur
    }

    enum VertexArray: GLuint {
        case ModelPoints
        case ModelLines
        case Canvas
    }

    var programs: [GLuint] = []
    var modelShaderUniforms: [GLint] = []
    var blurShaderUniforms: [GLint] = []
    var vertexArrays: [GLuint] = []
    var vertexBufferObjects: [GLuint] = []

    @IBOutlet var infoView: SKView!
    var gameScene: GameScene!
    var context: EAGLContext!
    let icosahedronModel = IcosahedronModel()
    var prevVertex: IcosahedronVertex!
    var currentVertex: IcosahedronVertex!
    var prevQuaternion = GLKQuaternionIdentity
    var currentQuaternion = GLKQuaternionIdentity
    var animationProgress: Float = 0.0
    var vertexTextureInfo: GLKTextureInfo!

    var modelViewProjectionMatrix = GLKMatrix4Identity
    var normalMatrix = GLKMatrix3Identity
    var modelFrameBufferObject: GLuint = 0
    var modelColorTexture: GLuint = 0
    var modelDepthRenderBufferObject: GLuint = 0
    var texelSize = GLKVector2Make(0, 0)

    deinit {

    }

    override func viewDidLoad() {

    }
}
