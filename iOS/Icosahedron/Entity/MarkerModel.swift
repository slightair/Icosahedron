import GLKit

class MarkerModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]

    let topCoordinate: GLKVector3

    init() {
        let scale: Float = 0.02
        let faceColor = GLKVector4Make(0.0, 1.0, 0.0, 1.0)

        let coordA = GLKVector3MultiplyScalar(GLKVector3Make(-1.0,  0.3, -1.0), scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make(-1.0, -0.3, -1.0), scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make(-0.7,  0.3,  0.0), scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-0.7, -0.3,  0.0), scale)
        let coordE = GLKVector3MultiplyScalar(GLKVector3Make(-1.0,  0.3,  1.0), scale)
        let coordF = GLKVector3MultiplyScalar(GLKVector3Make(-1.0, -0.3,  1.0), scale)
        let coordG = GLKVector3MultiplyScalar(GLKVector3Make( 1.0,  0.3,  0.0), scale)
        let coordH = GLKVector3MultiplyScalar(GLKVector3Make( 1.0, -0.3,  0.0), scale)

        let normalCGA = createFaceNormal(coordC, y: coordG, z: coordA)
        let normalEGC = createFaceNormal(coordE, y: coordG, z: coordC)
        let normalHGE = createFaceNormal(coordH, y: coordG, z: coordE)
        let normalFHE = createFaceNormal(coordF, y: coordH, z: coordE)
        let normalBHD = createFaceNormal(coordB, y: coordH, z: coordD)
        let normalDHF = createFaceNormal(coordD, y: coordH, z: coordF)
        let normalBAG = createFaceNormal(coordB, y: coordA, z: coordG)
        let normalHBG = createFaceNormal(coordH, y: coordB, z: coordG)
        let normalBCA = createFaceNormal(coordB, y: coordC, z: coordA)
        let normalDCB = createFaceNormal(coordD, y: coordC, z: coordB)
        let normalDEC = createFaceNormal(coordD, y: coordE, z: coordC)
        let normalFED = createFaceNormal(coordF, y: coordE, z: coordD)

        localModelVertices = [
            ModelVertex(position: coordC, normal: normalCGA, color: faceColor),
            ModelVertex(position: coordG, normal: normalCGA, color: faceColor),
            ModelVertex(position: coordA, normal: normalCGA, color: faceColor),

            ModelVertex(position: coordE, normal: normalEGC, color: faceColor),
            ModelVertex(position: coordG, normal: normalEGC, color: faceColor),
            ModelVertex(position: coordC, normal: normalEGC, color: faceColor),

            ModelVertex(position: coordH, normal: normalHGE, color: faceColor),
            ModelVertex(position: coordG, normal: normalHGE, color: faceColor),
            ModelVertex(position: coordE, normal: normalHGE, color: faceColor),

            ModelVertex(position: coordF, normal: normalFHE, color: faceColor),
            ModelVertex(position: coordH, normal: normalFHE, color: faceColor),
            ModelVertex(position: coordE, normal: normalFHE, color: faceColor),

            ModelVertex(position: coordB, normal: normalBHD, color: faceColor),
            ModelVertex(position: coordH, normal: normalBHD, color: faceColor),
            ModelVertex(position: coordD, normal: normalBHD, color: faceColor),

            ModelVertex(position: coordD, normal: normalDHF, color: faceColor),
            ModelVertex(position: coordH, normal: normalDHF, color: faceColor),
            ModelVertex(position: coordF, normal: normalDHF, color: faceColor),

            ModelVertex(position: coordB, normal: normalBAG, color: faceColor),
            ModelVertex(position: coordA, normal: normalBAG, color: faceColor),
            ModelVertex(position: coordG, normal: normalBAG, color: faceColor),

            ModelVertex(position: coordH, normal: normalHBG, color: faceColor),
            ModelVertex(position: coordB, normal: normalHBG, color: faceColor),
            ModelVertex(position: coordG, normal: normalHBG, color: faceColor),

            ModelVertex(position: coordB, normal: normalBCA, color: faceColor),
            ModelVertex(position: coordC, normal: normalBCA, color: faceColor),
            ModelVertex(position: coordA, normal: normalBCA, color: faceColor),

            ModelVertex(position: coordD, normal: normalDCB, color: faceColor),
            ModelVertex(position: coordC, normal: normalDCB, color: faceColor),
            ModelVertex(position: coordB, normal: normalDCB, color: faceColor),
            
            ModelVertex(position: coordD, normal: normalDEC, color: faceColor),
            ModelVertex(position: coordE, normal: normalDEC, color: faceColor),
            ModelVertex(position: coordC, normal: normalDEC, color: faceColor),
            
            ModelVertex(position: coordF, normal: normalFED, color: faceColor),
            ModelVertex(position: coordE, normal: normalFED, color: faceColor),
            ModelVertex(position: coordD, normal: normalFED, color: faceColor),
        ]

        topCoordinate = GLKVector3MultiplyScalar(GLKVector3Make(0, 1, 0), scale)
    }

    func setPosition(newPosition: GLKVector3) {
        position = newPosition
        quaternion = quaternionForRotate(from: topCoordinate, to: position)
    }
}
