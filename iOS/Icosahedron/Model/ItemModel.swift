import GLKit

class ItemModel: TetrahedronModel {
    override class var scale: Float {
        return 0.01
    }
    override class var faceColor: GLKVector4 {
        return GLKVector4Make(0.0, 0.5, 1.0, 1.0)
    }

    init(initialPosition: GLKVector3) {
        super.init()

        setPosition(initialPosition)
    }
}
