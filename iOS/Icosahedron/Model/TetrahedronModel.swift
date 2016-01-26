import GLKit

class TetrahedronModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    var scale = GLKVector3Make(1.0, 1.0, 1.0)
    var customColor: GLKVector4? = nil

    class var scale: Float {
        return 1.0
    }

    let topCoordinate: GLKVector3

    init(color: GLKVector4 = GLKVector4Make(1.0, 1.0, 1.0, 1.0)) {
        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1,  1,  1), self.dynamicType.scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make( 1, -1, -1), self.dynamicType.scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make(-1,  1, -1), self.dynamicType.scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-1, -1,  1), self.dynamicType.scale)

        let normalDCB = createFaceNormal(coordD, y: coordC, z: coordB)
        let normalCAB = createFaceNormal(coordC, y: coordA, z: coordB)
        let normalCDA = createFaceNormal(coordC, y: coordD, z: coordA)
        let normalBAD = createFaceNormal(coordB, y: coordA, z: coordD)

        let texCoord = GLKVector2Make(0, 0)

        localModelVertices = [
            ModelVertex(position: coordD, normal: normalDCB, color: color, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalDCB, color: color, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalDCB, color: color, texCoord: texCoord),

            ModelVertex(position: coordC, normal: normalCAB, color: color, texCoord: texCoord),
            ModelVertex(position: coordA, normal: normalCAB, color: color, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalCAB, color: color, texCoord: texCoord),

            ModelVertex(position: coordC, normal: normalCDA, color: color, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalCDA, color: color, texCoord: texCoord),
            ModelVertex(position: coordA, normal: normalCDA, color: color, texCoord: texCoord),

            ModelVertex(position: coordB, normal: normalBAD, color: color, texCoord: texCoord),
            ModelVertex(position: coordA, normal: normalBAD, color: color, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalBAD, color: color, texCoord: texCoord),
        ]

        topCoordinate = GLKVector3Make(-1, -1, -1)
    }
}
