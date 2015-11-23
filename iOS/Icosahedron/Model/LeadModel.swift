import GLKit

class LeadModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]

    class var scale: Float {
        return 1.0
    }

    class var leftColor: GLKVector4 {
        return GLKVector4Make(1.0, 0.0, 0.0, 1.0)
    }

    class var rightColor: GLKVector4 {
        return GLKVector4Make(0.0, 0.0, 1.0, 1.0)
    }

    let topCoordinate: GLKVector3
    let leftCoordinate: GLKVector3
    let rightCoordinate: GLKVector3

    init() {
        let coordA = GLKVector3MultiplyScalar(GLKVector3Make(-1, -0.01, 0), self.dynamicType.scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make(-1,  0.01, 0), self.dynamicType.scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make( 1, -0.01, 0), self.dynamicType.scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make( 1,  0.01, 0), self.dynamicType.scale)

        let normalACB = createFaceNormal(coordA, y: coordC, z: coordB)
        let normalCDB = createFaceNormal(coordC, y: coordD, z: coordB)

        localModelVertices = [
            ModelVertex(position: coordA, normal: normalACB, color: self.dynamicType.leftColor),
            ModelVertex(position: coordC, normal: normalACB, color: self.dynamicType.rightColor),
            ModelVertex(position: coordB, normal: normalACB, color: self.dynamicType.leftColor),

            ModelVertex(position: coordC, normal: normalCDB, color: self.dynamicType.rightColor),
            ModelVertex(position: coordD, normal: normalCDB, color: self.dynamicType.rightColor),
            ModelVertex(position: coordB, normal: normalCDB, color: self.dynamicType.leftColor),
        ]

        topCoordinate = GLKVector3Make(0, 0, 1)
        leftCoordinate = GLKVector3Make(-1, 0, 0)
        rightCoordinate = GLKVector3Make(1, 0, 0)
    }
}
