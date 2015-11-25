import GLKit

class ItemModel: TetrahedronModel {
    override class var scale: Float {
        return 0.01
    }

    static func colorOfKind(kind: Item.Kind) -> GLKVector4 {
        switch kind {
        case .Red:
            return GLKVector4Make(1.0, 0.0, 0.0, 1.0)
        case .Green:
            return GLKVector4Make(0.0, 1.0, 0.0, 1.0)
        case .Blue:
            return GLKVector4Make(0.0, 0.0, 1.0, 1.0)
        }
    }

    init(initialPosition: GLKVector3, kind: Item.Kind) {
        let color = ItemModel.colorOfKind(kind)
        super.init(color: color)

        setPosition(initialPosition)
    }

    func setPosition(newPosition: GLKVector3) {
        position = GLKVector3MultiplyScalar(newPosition, 1.1)
        quaternion = quaternionForRotate(from: topCoordinate, to: position)
    }
}
