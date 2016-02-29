import GLKit

class TrackModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]

    class var scale: Float {
        return 0.15
    }

    let topCoordinate: GLKVector3

    init(leftPosition: GLKVector3, rightPosition: GLKVector3, color: World.Color, alpha: CGFloat) {
        let coordA = GLKVector3MultiplyScalar(GLKVector3Make(-1, -0.02, 0), self.dynamicType.scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make(-1,  0.02, 0), self.dynamicType.scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make( 1, -0.02, 0), self.dynamicType.scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make( 1,  0.02, 0), self.dynamicType.scale)

        let normalACB = createFaceNormal(coordA, y: coordC, z: coordB)
        let normalCDB = createFaceNormal(coordC, y: coordD, z: coordB)

        let colorVector = color.modelColor(alpha)

        let texCoordA = GLKVector2Make(0, 0)
        let texCoordB = GLKVector2Make(0, 1)
        let texCoordC = GLKVector2Make(1, 0)
        let texCoordD = GLKVector2Make(1, 1)

        localModelVertices = [
            ModelVertex(position: coordA, normal: normalACB, color: colorVector, texCoord: texCoordA),
            ModelVertex(position: coordC, normal: normalACB, color: colorVector, texCoord: texCoordC),
            ModelVertex(position: coordB, normal: normalACB, color: colorVector, texCoord: texCoordB),

            ModelVertex(position: coordC, normal: normalCDB, color: colorVector, texCoord: texCoordC),
            ModelVertex(position: coordD, normal: normalCDB, color: colorVector, texCoord: texCoordD),
            ModelVertex(position: coordB, normal: normalCDB, color: colorVector, texCoord: texCoordB),
        ]

        topCoordinate = GLKVector3Make(0, 0, 1)
        position = GLKVector3Lerp(leftPosition, rightPosition, 0.5)

        let adjustTopQuaternion = quaternionForRotate(from: topCoordinate, to: position)
        let newLeftCoordinate = GLKQuaternionRotateVector3(adjustTopQuaternion, GLKVector3Make(-1, 0, 0))
        let desiredLeftCoordinate = GLKVector3CrossProduct(GLKVector3CrossProduct(position, leftPosition), position)
        let adjustLeftQuaternion = quaternionForRotate(from: newLeftCoordinate, to: desiredLeftCoordinate)

        quaternion = GLKQuaternionMultiply(adjustLeftQuaternion, adjustTopQuaternion)
    }
}
