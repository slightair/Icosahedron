import GLKit

class TetrahedronModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity

    var localModelVertices: [ModelVertex]
    let topCoordinate: GLKVector3

    init() {
        let scale: Float = 0.02

        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1, 1, 1), scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make( 1,-1,-1), scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make(-1, 1,-1), scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-1,-1, 1), scale)

        let normalDCB = createFaceNormal(coordD, y: coordC, z: coordB)
        let normalCAB = createFaceNormal(coordC, y: coordA, z: coordB)
        let normalCDA = createFaceNormal(coordC, y: coordD, z: coordA)
        let normalBAD = createFaceNormal(coordB, y: coordA, z: coordD)

        let faceColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)

        localModelVertices = [
            ModelVertex(position: coordD, normal: normalDCB, color: faceColor),
            ModelVertex(position: coordC, normal: normalDCB, color: faceColor),
            ModelVertex(position: coordB, normal: normalDCB, color: faceColor),

            ModelVertex(position: coordC, normal: normalCAB, color: faceColor),
            ModelVertex(position: coordA, normal: normalCAB, color: faceColor),
            ModelVertex(position: coordB, normal: normalCAB, color: faceColor),

            ModelVertex(position: coordC, normal: normalCDA, color: faceColor),
            ModelVertex(position: coordD, normal: normalCDA, color: faceColor),
            ModelVertex(position: coordA, normal: normalCDA, color: faceColor),

            ModelVertex(position: coordB, normal: normalBAD, color: faceColor),
            ModelVertex(position: coordA, normal: normalBAD, color: faceColor),
            ModelVertex(position: coordD, normal: normalBAD, color: faceColor),
        ]

        topCoordinate = coordA
    }
}
