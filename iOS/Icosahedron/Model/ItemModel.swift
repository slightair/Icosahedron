import GLKit
import ChameleonFramework

class ItemModel: TetrahedronModel {
    override class var scale: Float {
        return 0.01
    }

    static func colorOfKind(kind: Item.Kind) -> GLKVector4 {
        switch kind {
        case .Red:
            return UIColor.flatRedColor().glColor
        case .Green:
            return UIColor.flatGreenColor().glColor
        case .Blue:
            return UIColor.flatBlueColor().glColor
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
