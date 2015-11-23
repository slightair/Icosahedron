import GLKit

class RoadModel: LeadModel {
    override class var scale: Float {
        return 0.15
    }

    init(leftPosition: GLKVector3, rightPosition: GLKVector3) {
        super.init()

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
