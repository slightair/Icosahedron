import OpenGLES
import GLKit

protocol Renderable {
    var vertices: [Float] { get }
    var numberOfVertices: Int { get }
    var modelMatrix: GLKMatrix4 { get set }
    var quaternion: GLKQuaternion { get set }

    func prepare()
    func render()
}
