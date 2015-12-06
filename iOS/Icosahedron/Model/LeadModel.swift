import GLKit

class LeadModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    var customColor: GLKVector4? = nil

    class var scale: Float {
        return 1.0
    }

    let topCoordinate: GLKVector3
    let leftCoordinate: GLKVector3
    let rightCoordinate: GLKVector3

    init(leftColor: GLKVector4 = GLKVector4Make(1.0, 0.0, 0.0, 1.0), rightColor: GLKVector4 = GLKVector4Make(0.0, 0.0, 1.0, 1.0)) {
        let coordA = GLKVector3MultiplyScalar(GLKVector3Make(-1, -0.01, 0), self.dynamicType.scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make(-1,  0.01, 0), self.dynamicType.scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make( 1, -0.01, 0), self.dynamicType.scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make( 1,  0.01, 0), self.dynamicType.scale)

        let normalACB = createFaceNormal(coordA, y: coordC, z: coordB)
        let normalCDB = createFaceNormal(coordC, y: coordD, z: coordB)

        let texCoord = GLKVector2Make(0, 0)

        localModelVertices = [
            ModelVertex(position: coordA, normal: normalACB, color: leftColor, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalACB, color: rightColor, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalACB, color: leftColor, texCoord: texCoord),

            ModelVertex(position: coordC, normal: normalCDB, color: rightColor, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalCDB, color: rightColor, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalCDB, color: leftColor, texCoord: texCoord),
        ]

        topCoordinate = GLKVector3Make(0, 0, 1)
        leftCoordinate = GLKVector3Make(-1, 0, 0)
        rightCoordinate = GLKVector3Make(1, 0, 0)
    }
}
