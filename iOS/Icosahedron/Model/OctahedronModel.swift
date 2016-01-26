import GLKit

class OctahedronModel: Renderable {
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
        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1,  0), self.dynamicType.scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make( 0,  0, -1), self.dynamicType.scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make( 1,  0,  0), self.dynamicType.scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make( 0,  0,  1), self.dynamicType.scale)
        let coordE = GLKVector3MultiplyScalar(GLKVector3Make(-1,  0,  0), self.dynamicType.scale)
        let coordF = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1,  0), self.dynamicType.scale)

        let normalBAC = createFaceNormal(coordB, y: coordA, z: coordC)
        let normalCAD = createFaceNormal(coordC, y: coordA, z: coordD)
        let normalDAE = createFaceNormal(coordD, y: coordA, z: coordE)
        let normalEAB = createFaceNormal(coordE, y: coordA, z: coordB)
        let normalFBC = createFaceNormal(coordF, y: coordB, z: coordC)
        let normalFCD = createFaceNormal(coordF, y: coordC, z: coordD)
        let normalFDE = createFaceNormal(coordF, y: coordD, z: coordE)
        let normalFEB = createFaceNormal(coordF, y: coordE, z: coordB)

        let texCoord = GLKVector2Make(0, 0)

        localModelVertices = [
            ModelVertex(position: coordB, normal: normalBAC, color: color, texCoord: texCoord),
            ModelVertex(position: coordA, normal: normalBAC, color: color, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalBAC, color: color, texCoord: texCoord),

            ModelVertex(position: coordC, normal: normalCAD, color: color, texCoord: texCoord),
            ModelVertex(position: coordA, normal: normalCAD, color: color, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalCAD, color: color, texCoord: texCoord),

            ModelVertex(position: coordD, normal: normalDAE, color: color, texCoord: texCoord),
            ModelVertex(position: coordA, normal: normalDAE, color: color, texCoord: texCoord),
            ModelVertex(position: coordE, normal: normalDAE, color: color, texCoord: texCoord),

            ModelVertex(position: coordE, normal: normalEAB, color: color, texCoord: texCoord),
            ModelVertex(position: coordA, normal: normalEAB, color: color, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalEAB, color: color, texCoord: texCoord),

            ModelVertex(position: coordF, normal: normalFBC, color: color, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalFBC, color: color, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalFBC, color: color, texCoord: texCoord),

            ModelVertex(position: coordF, normal: normalFCD, color: color, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalFCD, color: color, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalFCD, color: color, texCoord: texCoord),

            ModelVertex(position: coordF, normal: normalFDE, color: color, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalFDE, color: color, texCoord: texCoord),
            ModelVertex(position: coordE, normal: normalFDE, color: color, texCoord: texCoord),

            ModelVertex(position: coordF, normal: normalFEB, color: color, texCoord: texCoord),
            ModelVertex(position: coordE, normal: normalFEB, color: color, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalFEB, color: color, texCoord: texCoord),
        ]

        topCoordinate = GLKVector3Make(0, 1, 0)
    }
}
