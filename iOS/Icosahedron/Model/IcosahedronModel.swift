import GLKit

class IcosahedronModel: Renderable {
    let position = GLKVector3Make(0.0, 0.0, 0.0)
    let quaternion = GLKQuaternionIdentity
    let localModelVertices: [ModelVertex]
    let icosahedronVertices: [IcosahedronVertex]
    var customColor: GLKVector4? = nil

    class var scale: Float {
        return 1.0
    }

    class var faceColor: GLKVector4 {
        return GLKVector4Make(1.0, 1.0, 1.0, 1.0)
    }

    init() {
        let ratio: Float = (1.0 + sqrt(5.0)) / 2.0

        let coordG = GLKVector3MultiplyScalar(GLKVector3Make( ratio,  0,  1), self.dynamicType.scale)
        let coordE = GLKVector3MultiplyScalar(GLKVector3Make( ratio,  0, -1), self.dynamicType.scale)
        let coordH = GLKVector3MultiplyScalar(GLKVector3Make(-ratio,  0,  1), self.dynamicType.scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-ratio,  0, -1), self.dynamicType.scale)
        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1,  ratio,  0), self.dynamicType.scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make(-1,  ratio,  0), self.dynamicType.scale)
        let coordK = GLKVector3MultiplyScalar(GLKVector3Make( 1, -ratio,  0), self.dynamicType.scale)
        let coordJ = GLKVector3MultiplyScalar(GLKVector3Make(-1, -ratio,  0), self.dynamicType.scale)
        let coordF = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1,  ratio), self.dynamicType.scale)
        let coordL = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1,  ratio), self.dynamicType.scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1, -ratio), self.dynamicType.scale)
        let coordI = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1, -ratio), self.dynamicType.scale)

        let normalABF = createFaceNormal(coordA, y: coordB, z: coordF)
        let normalACB = createFaceNormal(coordA, y: coordC, z: coordB)
        let normalAEC = createFaceNormal(coordA, y: coordE, z: coordC)
        let normalAFG = createFaceNormal(coordA, y: coordF, z: coordG)
        let normalAGE = createFaceNormal(coordA, y: coordG, z: coordE)
        let normalBCD = createFaceNormal(coordB, y: coordC, z: coordD)
        let normalBDH = createFaceNormal(coordB, y: coordD, z: coordH)
        let normalBHF = createFaceNormal(coordB, y: coordH, z: coordF)
        let normalCEI = createFaceNormal(coordC, y: coordE, z: coordI)
        let normalCID = createFaceNormal(coordC, y: coordI, z: coordD)
        let normalDIJ = createFaceNormal(coordD, y: coordI, z: coordJ)
        let normalDJH = createFaceNormal(coordD, y: coordJ, z: coordH)
        let normalEGK = createFaceNormal(coordE, y: coordG, z: coordK)
        let normalEKI = createFaceNormal(coordE, y: coordK, z: coordI)
        let normalFHL = createFaceNormal(coordF, y: coordH, z: coordL)
        let normalFLG = createFaceNormal(coordF, y: coordL, z: coordG)
        let normalGLK = createFaceNormal(coordG, y: coordL, z: coordK)
        let normalHJL = createFaceNormal(coordH, y: coordJ, z: coordL)
        let normalIKJ = createFaceNormal(coordI, y: coordK, z: coordJ)
        let normalJKL = createFaceNormal(coordJ, y: coordK, z: coordL)

        let texCoord = GLKVector2Make(0, 0)

        localModelVertices = [
            ModelVertex(position: coordA, normal: normalABF, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalABF, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordF, normal: normalABF, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordA, normal: normalACB, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalACB, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalACB, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordA, normal: normalAEC, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordE, normal: normalAEC, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalAEC, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordA, normal: normalAFG, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordF, normal: normalAFG, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordG, normal: normalAFG, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordA, normal: normalAGE, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordG, normal: normalAGE, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordE, normal: normalAGE, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordB, normal: normalBCD, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalBCD, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalBCD, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordB, normal: normalBDH, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalBDH, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordH, normal: normalBDH, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordB, normal: normalBHF, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordH, normal: normalBHF, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordF, normal: normalBHF, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordC, normal: normalCEI, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordE, normal: normalCEI, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordI, normal: normalCEI, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordC, normal: normalCID, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordI, normal: normalCID, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalCID, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordD, normal: normalDIJ, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordI, normal: normalDIJ, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordJ, normal: normalDIJ, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordD, normal: normalDJH, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordJ, normal: normalDJH, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordH, normal: normalDJH, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordE, normal: normalEGK, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordG, normal: normalEGK, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordK, normal: normalEGK, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordE, normal: normalEKI, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordK, normal: normalEKI, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordI, normal: normalEKI, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordF, normal: normalFHL, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordH, normal: normalFHL, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordL, normal: normalFHL, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordF, normal: normalFLG, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordL, normal: normalFLG, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordG, normal: normalFLG, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordG, normal: normalGLK, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordL, normal: normalGLK, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordK, normal: normalGLK, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordH, normal: normalHJL, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordJ, normal: normalHJL, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordL, normal: normalHJL, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordI, normal: normalIKJ, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordK, normal: normalIKJ, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordJ, normal: normalIKJ, color: self.dynamicType.faceColor, texCoord: texCoord),

            ModelVertex(position: coordJ, normal: normalJKL, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordK, normal: normalJKL, color: self.dynamicType.faceColor, texCoord: texCoord),
            ModelVertex(position: coordL, normal: normalJKL, color: self.dynamicType.faceColor, texCoord: texCoord),
        ]

        icosahedronVertices = [
            IcosahedronVertex(point: .A, coordinate: coordA),
            IcosahedronVertex(point: .B, coordinate: coordB),
            IcosahedronVertex(point: .C, coordinate: coordC),
            IcosahedronVertex(point: .D, coordinate: coordD),
            IcosahedronVertex(point: .E, coordinate: coordE),
            IcosahedronVertex(point: .F, coordinate: coordF),
            IcosahedronVertex(point: .G, coordinate: coordG),
            IcosahedronVertex(point: .H, coordinate: coordH),
            IcosahedronVertex(point: .I, coordinate: coordI),
            IcosahedronVertex(point: .J, coordinate: coordJ),
            IcosahedronVertex(point: .K, coordinate: coordK),
            IcosahedronVertex(point: .L, coordinate: coordL),
        ]
    }
}
