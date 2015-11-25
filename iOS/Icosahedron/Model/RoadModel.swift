import GLKit

class RoadModel: LeadModel {
    override class var scale: Float {
        return 0.15
    }

    static func colorOfKind(kind: Road.Kind) -> GLKVector4 {
        switch kind {
        case .Red:
            return GLKVector4Make(1.0, 0.0, 0.0, 1.0)
        case .Green:
            return GLKVector4Make(0.0, 1.0, 0.0, 1.0)
        case .Blue:
            return GLKVector4Make(0.0, 0.0, 1.0, 1.0)
        }
    }

    init(leftPosition: GLKVector3, rightPosition: GLKVector3, kind: Road.Kind) {
        let color = RoadModel.colorOfKind(kind)
        super.init(leftColor: color, rightColor: color)

        setPosition(leftPosition, right: rightPosition)
    }

    func setPosition(left: GLKVector3, right: GLKVector3) {
        position = GLKVector3Lerp(left, right, 0.5)

        let adjustTopQuaternion = quaternionForRotate(from: topCoordinate, to: position)
        let newLeftCoordinate = GLKQuaternionRotateVector3(adjustTopQuaternion, leftCoordinate)
        let desiredLeftCoordinate = GLKVector3CrossProduct(GLKVector3CrossProduct(position, left), position)
        let adjustLeftQuaternion = quaternionForRotate(from: newLeftCoordinate, to: desiredLeftCoordinate)
        quaternion = GLKQuaternionMultiply(adjustLeftQuaternion, adjustTopQuaternion)
    }
}
