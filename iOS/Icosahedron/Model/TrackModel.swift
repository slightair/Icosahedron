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
        let width: Float = 0.05

        let coordA = GLKVector3MultiplyScalar(GLKVector3Make(-1, -width, 0), self.dynamicType.scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make(-1,  width, 0), self.dynamicType.scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make(-1 + width, -width, 0), self.dynamicType.scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-1 + width,  width, 0), self.dynamicType.scale)
        let coordE = GLKVector3MultiplyScalar(GLKVector3Make( 1 - width, -width, 0), self.dynamicType.scale)
        let coordF = GLKVector3MultiplyScalar(GLKVector3Make( 1 - width,  width, 0), self.dynamicType.scale)
        let coordG = GLKVector3MultiplyScalar(GLKVector3Make( 1, -width, 0), self.dynamicType.scale)
        let coordH = GLKVector3MultiplyScalar(GLKVector3Make( 1,  width, 0), self.dynamicType.scale)

        let normal = createFaceNormal(coordA, y: coordC, z: coordB)

        let colorVector = color.modelColor(alpha)

        let texCoordA = GLKVector2Make(0, 0)
        let texCoordB = GLKVector2Make(0, 1)
        let texCoordC = GLKVector2Make(0.5, 0)
        let texCoordD = GLKVector2Make(0.5, 1)
        let texCoordE = GLKVector2Make(0.5, 0)
        let texCoordF = GLKVector2Make(0.5, 1)
        let texCoordG = GLKVector2Make(1, 0)
        let texCoordH = GLKVector2Make(1, 1)

        localModelVertices = [
            ModelVertex(position: coordA, normal: normal, color: colorVector, texCoord: texCoordA),
            ModelVertex(position: coordC, normal: normal, color: colorVector, texCoord: texCoordC),
            ModelVertex(position: coordB, normal: normal, color: colorVector, texCoord: texCoordB),

            ModelVertex(position: coordC, normal: normal, color: colorVector, texCoord: texCoordC),
            ModelVertex(position: coordD, normal: normal, color: colorVector, texCoord: texCoordD),
            ModelVertex(position: coordB, normal: normal, color: colorVector, texCoord: texCoordB),

            ModelVertex(position: coordC, normal: normal, color: colorVector, texCoord: texCoordC),
            ModelVertex(position: coordE, normal: normal, color: colorVector, texCoord: texCoordE),
            ModelVertex(position: coordD, normal: normal, color: colorVector, texCoord: texCoordD),

            ModelVertex(position: coordE, normal: normal, color: colorVector, texCoord: texCoordE),
            ModelVertex(position: coordF, normal: normal, color: colorVector, texCoord: texCoordF),
            ModelVertex(position: coordD, normal: normal, color: colorVector, texCoord: texCoordD),

            ModelVertex(position: coordE, normal: normal, color: colorVector, texCoord: texCoordE),
            ModelVertex(position: coordG, normal: normal, color: colorVector, texCoord: texCoordG),
            ModelVertex(position: coordF, normal: normal, color: colorVector, texCoord: texCoordF),

            ModelVertex(position: coordG, normal: normal, color: colorVector, texCoord: texCoordG),
            ModelVertex(position: coordH, normal: normal, color: colorVector, texCoord: texCoordH),
            ModelVertex(position: coordF, normal: normal, color: colorVector, texCoord: texCoordF),
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
