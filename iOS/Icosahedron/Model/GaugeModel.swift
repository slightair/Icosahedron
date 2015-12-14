import GLKit

class GaugeModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex] = []
    var customColor: GLKVector4? = nil

    init() {
        
    }
}
