import GLKit

class TetrahedronModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    var customColor: GLKVector4? = nil

    class var scale: Float {
        return 1.0
    }

    let topCoordinate: GLKVector3

    init(color: GLKVector4 = GLKVector4Make(1.0, 1.0, 1.0, 1.0)) {
        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1, 1, 1), self.dynamicType.scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make( 1,-1,-1), self.dynamicType.scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make(-1, 1,-1), self.dynamicType.scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-1,-1, 1), self.dynamicType.scale)

        let normalDCB = createFaceNormal(coordD, y: coordC, z: coordB)
        let normalCAB = createFaceNormal(coordC, y: coordA, z: coordB)
        let normalCDA = createFaceNormal(coordC, y: coordD, z: coordA)
        let normalBAD = createFaceNormal(coordB, y: coordA, z: coordD)

        localModelVertices = [
            ModelVertex(position: coordD, normal: normalDCB, color: color),
            ModelVertex(position: coordC, normal: normalDCB, color: color),
            ModelVertex(position: coordB, normal: normalDCB, color: color),

            ModelVertex(position: coordC, normal: normalCAB, color: color),
            ModelVertex(position: coordA, normal: normalCAB, color: color),
            ModelVertex(position: coordB, normal: normalCAB, color: color),

            ModelVertex(position: coordC, normal: normalCDA, color: color),
            ModelVertex(position: coordD, normal: normalCDA, color: color),
            ModelVertex(position: coordA, normal: normalCDA, color: color),

            ModelVertex(position: coordB, normal: normalBAD, color: color),
            ModelVertex(position: coordA, normal: normalBAD, color: color),
            ModelVertex(position: coordD, normal: normalBAD, color: color),
        ]

        topCoordinate = GLKVector3Make(-1, -1, -1)
    }
}
