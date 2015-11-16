import GLKit

class IcosahedronModel: Renderable {
    let position = GLKVector3Make(0.0, 0.0, 0.0)
    let quaternion = GLKQuaternionIdentity
    let localModelVertices: [ModelVertex]

    class var scale: Float {
        return 0.15
    }
    class var faceColor: GLKVector4 {
        return GLKVector4Make(1.0, 1.0, 1.0, 1.0)
    }
    var pointDict: [IcosahedronVertex.Point: IcosahedronVertex] = [:]

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

        localModelVertices = [
            ModelVertex(position: coordA, normal: normalABF, color: self.dynamicType.faceColor),
            ModelVertex(position: coordB, normal: normalABF, color: self.dynamicType.faceColor),
            ModelVertex(position: coordF, normal: normalABF, color: self.dynamicType.faceColor),

            ModelVertex(position: coordA, normal: normalACB, color: self.dynamicType.faceColor),
            ModelVertex(position: coordC, normal: normalACB, color: self.dynamicType.faceColor),
            ModelVertex(position: coordB, normal: normalACB, color: self.dynamicType.faceColor),

            ModelVertex(position: coordA, normal: normalAEC, color: self.dynamicType.faceColor),
            ModelVertex(position: coordE, normal: normalAEC, color: self.dynamicType.faceColor),
            ModelVertex(position: coordC, normal: normalAEC, color: self.dynamicType.faceColor),

            ModelVertex(position: coordA, normal: normalAFG, color: self.dynamicType.faceColor),
            ModelVertex(position: coordF, normal: normalAFG, color: self.dynamicType.faceColor),
            ModelVertex(position: coordG, normal: normalAFG, color: self.dynamicType.faceColor),

            ModelVertex(position: coordA, normal: normalAGE, color: self.dynamicType.faceColor),
            ModelVertex(position: coordG, normal: normalAGE, color: self.dynamicType.faceColor),
            ModelVertex(position: coordE, normal: normalAGE, color: self.dynamicType.faceColor),

            ModelVertex(position: coordB, normal: normalBCD, color: self.dynamicType.faceColor),
            ModelVertex(position: coordC, normal: normalBCD, color: self.dynamicType.faceColor),
            ModelVertex(position: coordD, normal: normalBCD, color: self.dynamicType.faceColor),

            ModelVertex(position: coordB, normal: normalBDH, color: self.dynamicType.faceColor),
            ModelVertex(position: coordD, normal: normalBDH, color: self.dynamicType.faceColor),
            ModelVertex(position: coordH, normal: normalBDH, color: self.dynamicType.faceColor),

            ModelVertex(position: coordB, normal: normalBHF, color: self.dynamicType.faceColor),
            ModelVertex(position: coordH, normal: normalBHF, color: self.dynamicType.faceColor),
            ModelVertex(position: coordF, normal: normalBHF, color: self.dynamicType.faceColor),

            ModelVertex(position: coordC, normal: normalCEI, color: self.dynamicType.faceColor),
            ModelVertex(position: coordE, normal: normalCEI, color: self.dynamicType.faceColor),
            ModelVertex(position: coordI, normal: normalCEI, color: self.dynamicType.faceColor),

            ModelVertex(position: coordC, normal: normalCID, color: self.dynamicType.faceColor),
            ModelVertex(position: coordI, normal: normalCID, color: self.dynamicType.faceColor),
            ModelVertex(position: coordD, normal: normalCID, color: self.dynamicType.faceColor),

            ModelVertex(position: coordD, normal: normalDIJ, color: self.dynamicType.faceColor),
            ModelVertex(position: coordI, normal: normalDIJ, color: self.dynamicType.faceColor),
            ModelVertex(position: coordJ, normal: normalDIJ, color: self.dynamicType.faceColor),

            ModelVertex(position: coordD, normal: normalDJH, color: self.dynamicType.faceColor),
            ModelVertex(position: coordJ, normal: normalDJH, color: self.dynamicType.faceColor),
            ModelVertex(position: coordH, normal: normalDJH, color: self.dynamicType.faceColor),

            ModelVertex(position: coordE, normal: normalEGK, color: self.dynamicType.faceColor),
            ModelVertex(position: coordG, normal: normalEGK, color: self.dynamicType.faceColor),
            ModelVertex(position: coordK, normal: normalEGK, color: self.dynamicType.faceColor),

            ModelVertex(position: coordE, normal: normalEKI, color: self.dynamicType.faceColor),
            ModelVertex(position: coordK, normal: normalEKI, color: self.dynamicType.faceColor),
            ModelVertex(position: coordI, normal: normalEKI, color: self.dynamicType.faceColor),

            ModelVertex(position: coordF, normal: normalFHL, color: self.dynamicType.faceColor),
            ModelVertex(position: coordH, normal: normalFHL, color: self.dynamicType.faceColor),
            ModelVertex(position: coordL, normal: normalFHL, color: self.dynamicType.faceColor),

            ModelVertex(position: coordF, normal: normalFLG, color: self.dynamicType.faceColor),
            ModelVertex(position: coordL, normal: normalFLG, color: self.dynamicType.faceColor),
            ModelVertex(position: coordG, normal: normalFLG, color: self.dynamicType.faceColor),

            ModelVertex(position: coordG, normal: normalGLK, color: self.dynamicType.faceColor),
            ModelVertex(position: coordL, normal: normalGLK, color: self.dynamicType.faceColor),
            ModelVertex(position: coordK, normal: normalGLK, color: self.dynamicType.faceColor),

            ModelVertex(position: coordH, normal: normalHJL, color: self.dynamicType.faceColor),
            ModelVertex(position: coordJ, normal: normalHJL, color: self.dynamicType.faceColor),
            ModelVertex(position: coordL, normal: normalHJL, color: self.dynamicType.faceColor),

            ModelVertex(position: coordI, normal: normalIKJ, color: self.dynamicType.faceColor),
            ModelVertex(position: coordK, normal: normalIKJ, color: self.dynamicType.faceColor),
            ModelVertex(position: coordJ, normal: normalIKJ, color: self.dynamicType.faceColor),

            ModelVertex(position: coordJ, normal: normalJKL, color: self.dynamicType.faceColor),
            ModelVertex(position: coordK, normal: normalJKL, color: self.dynamicType.faceColor),
            ModelVertex(position: coordL, normal: normalJKL, color: self.dynamicType.faceColor),
        ]

        let icosahedronVertices = [
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

        for vertex in icosahedronVertices {
            pointDict[vertex.point] = vertex
        }

        pointDict[.C]!.head      = pointDict[.I]
        pointDict[.C]!.leftHand  = pointDict[.D]
        pointDict[.C]!.leftFoot  = pointDict[.B]
        pointDict[.C]!.rightHand = pointDict[.E]
        pointDict[.C]!.rightFoot = pointDict[.A]

        pointDict[.B]!.head      = pointDict[.A]
        pointDict[.B]!.leftHand  = pointDict[.C]
        pointDict[.B]!.leftFoot  = pointDict[.D]
        pointDict[.B]!.rightHand = pointDict[.H]
        pointDict[.B]!.rightFoot = pointDict[.F]

        pointDict[.A]!.head      = pointDict[.E]
        pointDict[.A]!.leftHand  = pointDict[.C]
        pointDict[.A]!.leftFoot  = pointDict[.B]
        pointDict[.A]!.rightHand = pointDict[.F]
        pointDict[.A]!.rightFoot = pointDict[.G]

        pointDict[.E]!.head      = pointDict[.G]
        pointDict[.E]!.leftHand  = pointDict[.K]
        pointDict[.E]!.leftFoot  = pointDict[.I]
        pointDict[.E]!.rightHand = pointDict[.C]
        pointDict[.E]!.rightFoot = pointDict[.A]

        pointDict[.G]!.head      = pointDict[.L]
        pointDict[.G]!.leftHand  = pointDict[.K]
        pointDict[.G]!.leftFoot  = pointDict[.E]
        pointDict[.G]!.rightHand = pointDict[.A]
        pointDict[.G]!.rightFoot = pointDict[.F]

        pointDict[.L]!.head      = pointDict[.F]
        pointDict[.L]!.leftHand  = pointDict[.H]
        pointDict[.L]!.leftFoot  = pointDict[.J]
        pointDict[.L]!.rightHand = pointDict[.K]
        pointDict[.L]!.rightFoot = pointDict[.G]

        pointDict[.F]!.head      = pointDict[.H]
        pointDict[.F]!.leftHand  = pointDict[.L]
        pointDict[.F]!.leftFoot  = pointDict[.G]
        pointDict[.F]!.rightHand = pointDict[.A]
        pointDict[.F]!.rightFoot = pointDict[.B]

        pointDict[.H]!.head      = pointDict[.J]
        pointDict[.H]!.leftHand  = pointDict[.L]
        pointDict[.H]!.leftFoot  = pointDict[.F]
        pointDict[.H]!.rightHand = pointDict[.B]
        pointDict[.H]!.rightFoot = pointDict[.D]

        pointDict[.J]!.head      = pointDict[.K]
        pointDict[.J]!.leftHand  = pointDict[.L]
        pointDict[.J]!.leftFoot  = pointDict[.H]
        pointDict[.J]!.rightHand = pointDict[.D]
        pointDict[.J]!.rightFoot = pointDict[.I]

        pointDict[.K]!.head      = pointDict[.I]
        pointDict[.K]!.leftHand  = pointDict[.E]
        pointDict[.K]!.leftFoot  = pointDict[.G]
        pointDict[.K]!.rightHand = pointDict[.L]
        pointDict[.K]!.rightFoot = pointDict[.J]

        pointDict[.I]!.head      = pointDict[.D]
        pointDict[.I]!.leftHand  = pointDict[.C]
        pointDict[.I]!.leftFoot  = pointDict[.E]
        pointDict[.I]!.rightHand = pointDict[.K]
        pointDict[.I]!.rightFoot = pointDict[.J]

        pointDict[.D]!.head      = pointDict[.C]
        pointDict[.D]!.leftHand  = pointDict[.I]
        pointDict[.D]!.leftFoot  = pointDict[.J]
        pointDict[.D]!.rightHand = pointDict[.H]
        pointDict[.D]!.rightFoot = pointDict[.B]
    }
}
