import GLKit

class TetrahedronModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]

    class var scale: Float {
        return 1.0
    }
    class var faceColor: GLKVector4 {
        return GLKVector4Make(1.0, 1.0, 1.0, 1.0)
    }
    let topCoordinate: GLKVector3

    init() {
        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1, 1, 1), self.dynamicType.scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make( 1,-1,-1), self.dynamicType.scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make(-1, 1,-1), self.dynamicType.scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-1,-1, 1), self.dynamicType.scale)

        let normalDCB = createFaceNormal(coordD, y: coordC, z: coordB)
        let normalCAB = createFaceNormal(coordC, y: coordA, z: coordB)
        let normalCDA = createFaceNormal(coordC, y: coordD, z: coordA)
        let normalBAD = createFaceNormal(coordB, y: coordA, z: coordD)

        localModelVertices = [
            ModelVertex(position: coordD, normal: normalDCB, color: self.dynamicType.faceColor),
            ModelVertex(position: coordC, normal: normalDCB, color: self.dynamicType.faceColor),
            ModelVertex(position: coordB, normal: normalDCB, color: self.dynamicType.faceColor),

            ModelVertex(position: coordC, normal: normalCAB, color: self.dynamicType.faceColor),
            ModelVertex(position: coordA, normal: normalCAB, color: self.dynamicType.faceColor),
            ModelVertex(position: coordB, normal: normalCAB, color: self.dynamicType.faceColor),

            ModelVertex(position: coordC, normal: normalCDA, color: self.dynamicType.faceColor),
            ModelVertex(position: coordD, normal: normalCDA, color: self.dynamicType.faceColor),
            ModelVertex(position: coordA, normal: normalCDA, color: self.dynamicType.faceColor),

            ModelVertex(position: coordB, normal: normalBAD, color: self.dynamicType.faceColor),
            ModelVertex(position: coordA, normal: normalBAD, color: self.dynamicType.faceColor),
            ModelVertex(position: coordD, normal: normalBAD, color: self.dynamicType.faceColor),
        ]

        topCoordinate = GLKVector3MultiplyScalar(GLKVector3Make(-1,-1,-1), self.dynamicType.scale)
    }

    func setPosition(newPosition: GLKVector3) {
        position = GLKVector3MultiplyScalar(newPosition, 1.1)
        quaternion = quaternionForRotate(from: topCoordinate, to: position)
    }
}
