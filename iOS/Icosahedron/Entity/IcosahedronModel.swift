import GLKit

class IcosahedronModel: Renderable {
    let position = GLKVector3Make(0.0, 0.0, 0.0)
    let quaternion = GLKQuaternionIdentity

    var localModelVertices: [ModelVertex]
    var pointDict: [String: IcosahedronVertex] = [:]

    init() {
        let ratio: Float = (1.0 + sqrt(5.0)) / 2.0
        let scale: Float = 0.15

        let coordG = GLKVector3MultiplyScalar(GLKVector3Make( ratio,  0,  1), scale)
        let coordE = GLKVector3MultiplyScalar(GLKVector3Make( ratio,  0, -1), scale)
        let coordH = GLKVector3MultiplyScalar(GLKVector3Make(-ratio,  0,  1), scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-ratio,  0, -1), scale)
        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1,  ratio,  0), scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make(-1,  ratio,  0), scale)
        let coordK = GLKVector3MultiplyScalar(GLKVector3Make( 1, -ratio,  0), scale)
        let coordJ = GLKVector3MultiplyScalar(GLKVector3Make(-1, -ratio,  0), scale)
        let coordF = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1,  ratio), scale)
        let coordL = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1,  ratio), scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1, -ratio), scale)
        let coordI = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1, -ratio), scale)

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

        let faceColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)

        localModelVertices = [
            ModelVertex(position: coordA, normal: normalABF, color: faceColor),
            ModelVertex(position: coordB, normal: normalABF, color: faceColor),
            ModelVertex(position: coordF, normal: normalABF, color: faceColor),

            ModelVertex(position: coordA, normal: normalACB, color: faceColor),
            ModelVertex(position: coordC, normal: normalACB, color: faceColor),
            ModelVertex(position: coordB, normal: normalACB, color: faceColor),

            ModelVertex(position: coordA, normal: normalAEC, color: faceColor),
            ModelVertex(position: coordE, normal: normalAEC, color: faceColor),
            ModelVertex(position: coordC, normal: normalAEC, color: faceColor),

            ModelVertex(position: coordA, normal: normalAFG, color: faceColor),
            ModelVertex(position: coordF, normal: normalAFG, color: faceColor),
            ModelVertex(position: coordG, normal: normalAFG, color: faceColor),

            ModelVertex(position: coordA, normal: normalAGE, color: faceColor),
            ModelVertex(position: coordG, normal: normalAGE, color: faceColor),
            ModelVertex(position: coordE, normal: normalAGE, color: faceColor),

            ModelVertex(position: coordB, normal: normalBCD, color: faceColor),
            ModelVertex(position: coordC, normal: normalBCD, color: faceColor),
            ModelVertex(position: coordD, normal: normalBCD, color: faceColor),

            ModelVertex(position: coordB, normal: normalBDH, color: faceColor),
            ModelVertex(position: coordD, normal: normalBDH, color: faceColor),
            ModelVertex(position: coordH, normal: normalBDH, color: faceColor),

            ModelVertex(position: coordB, normal: normalBHF, color: faceColor),
            ModelVertex(position: coordH, normal: normalBHF, color: faceColor),
            ModelVertex(position: coordF, normal: normalBHF, color: faceColor),

            ModelVertex(position: coordC, normal: normalCEI, color: faceColor),
            ModelVertex(position: coordE, normal: normalCEI, color: faceColor),
            ModelVertex(position: coordI, normal: normalCEI, color: faceColor),

            ModelVertex(position: coordC, normal: normalCID, color: faceColor),
            ModelVertex(position: coordI, normal: normalCID, color: faceColor),
            ModelVertex(position: coordD, normal: normalCID, color: faceColor),

            ModelVertex(position: coordD, normal: normalDIJ, color: faceColor),
            ModelVertex(position: coordI, normal: normalDIJ, color: faceColor),
            ModelVertex(position: coordJ, normal: normalDIJ, color: faceColor),

            ModelVertex(position: coordD, normal: normalDJH, color: faceColor),
            ModelVertex(position: coordJ, normal: normalDJH, color: faceColor),
            ModelVertex(position: coordH, normal: normalDJH, color: faceColor),

            ModelVertex(position: coordE, normal: normalEGK, color: faceColor),
            ModelVertex(position: coordG, normal: normalEGK, color: faceColor),
            ModelVertex(position: coordK, normal: normalEGK, color: faceColor),

            ModelVertex(position: coordE, normal: normalEKI, color: faceColor),
            ModelVertex(position: coordK, normal: normalEKI, color: faceColor),
            ModelVertex(position: coordI, normal: normalEKI, color: faceColor),

            ModelVertex(position: coordF, normal: normalFHL, color: faceColor),
            ModelVertex(position: coordH, normal: normalFHL, color: faceColor),
            ModelVertex(position: coordL, normal: normalFHL, color: faceColor),

            ModelVertex(position: coordF, normal: normalFLG, color: faceColor),
            ModelVertex(position: coordL, normal: normalFLG, color: faceColor),
            ModelVertex(position: coordG, normal: normalFLG, color: faceColor),

            ModelVertex(position: coordG, normal: normalGLK, color: faceColor),
            ModelVertex(position: coordL, normal: normalGLK, color: faceColor),
            ModelVertex(position: coordK, normal: normalGLK, color: faceColor),

            ModelVertex(position: coordH, normal: normalHJL, color: faceColor),
            ModelVertex(position: coordJ, normal: normalHJL, color: faceColor),
            ModelVertex(position: coordL, normal: normalHJL, color: faceColor),

            ModelVertex(position: coordI, normal: normalIKJ, color: faceColor),
            ModelVertex(position: coordK, normal: normalIKJ, color: faceColor),
            ModelVertex(position: coordJ, normal: normalIKJ, color: faceColor),

            ModelVertex(position: coordJ, normal: normalJKL, color: faceColor),
            ModelVertex(position: coordK, normal: normalJKL, color: faceColor),
            ModelVertex(position: coordL, normal: normalJKL, color: faceColor),
        ]

        let points = [
            IcosahedronVertex(name: "A", coordinate: coordA),
            IcosahedronVertex(name: "B", coordinate: coordB),
            IcosahedronVertex(name: "C", coordinate: coordC),
            IcosahedronVertex(name: "D", coordinate: coordD),
            IcosahedronVertex(name: "E", coordinate: coordE),
            IcosahedronVertex(name: "F", coordinate: coordF),
            IcosahedronVertex(name: "G", coordinate: coordG),
            IcosahedronVertex(name: "H", coordinate: coordH),
            IcosahedronVertex(name: "I", coordinate: coordI),
            IcosahedronVertex(name: "J", coordinate: coordJ),
            IcosahedronVertex(name: "K", coordinate: coordK),
            IcosahedronVertex(name: "L", coordinate: coordL),
        ]

        for point in points {
            pointDict[point.name] = point
        }

        pointDict["C"]!.head      = pointDict["I"]
        pointDict["C"]!.leftHand  = pointDict["D"]
        pointDict["C"]!.leftFoot  = pointDict["B"]
        pointDict["C"]!.rightHand = pointDict["E"]
        pointDict["C"]!.rightFoot = pointDict["A"]

        pointDict["B"]!.head      = pointDict["A"]
        pointDict["B"]!.leftHand  = pointDict["C"]
        pointDict["B"]!.leftFoot  = pointDict["D"]
        pointDict["B"]!.rightHand = pointDict["H"]
        pointDict["B"]!.rightFoot = pointDict["F"]

        pointDict["A"]!.head      = pointDict["E"]
        pointDict["A"]!.leftHand  = pointDict["C"]
        pointDict["A"]!.leftFoot  = pointDict["B"]
        pointDict["A"]!.rightHand = pointDict["F"]
        pointDict["A"]!.rightFoot = pointDict["G"]

        pointDict["E"]!.head      = pointDict["G"]
        pointDict["E"]!.leftHand  = pointDict["K"]
        pointDict["E"]!.leftFoot  = pointDict["I"]
        pointDict["E"]!.rightHand = pointDict["C"]
        pointDict["E"]!.rightFoot = pointDict["A"]

        pointDict["G"]!.head      = pointDict["L"]
        pointDict["G"]!.leftHand  = pointDict["K"]
        pointDict["G"]!.leftFoot  = pointDict["E"]
        pointDict["G"]!.rightHand = pointDict["A"]
        pointDict["G"]!.rightFoot = pointDict["F"]

        pointDict["L"]!.head      = pointDict["F"]
        pointDict["L"]!.leftHand  = pointDict["H"]
        pointDict["L"]!.leftFoot  = pointDict["J"]
        pointDict["L"]!.rightHand = pointDict["K"]
        pointDict["L"]!.rightFoot = pointDict["G"]

        pointDict["F"]!.head      = pointDict["H"]
        pointDict["F"]!.leftHand  = pointDict["L"]
        pointDict["F"]!.leftFoot  = pointDict["G"]
        pointDict["F"]!.rightHand = pointDict["A"]
        pointDict["F"]!.rightFoot = pointDict["B"]

        pointDict["H"]!.head      = pointDict["J"]
        pointDict["H"]!.leftHand  = pointDict["L"]
        pointDict["H"]!.leftFoot  = pointDict["F"]
        pointDict["H"]!.rightHand = pointDict["B"]
        pointDict["H"]!.rightFoot = pointDict["D"]

        pointDict["J"]!.head      = pointDict["K"]
        pointDict["J"]!.leftHand  = pointDict["L"]
        pointDict["J"]!.leftFoot  = pointDict["H"]
        pointDict["J"]!.rightHand = pointDict["D"]
        pointDict["J"]!.rightFoot = pointDict["I"]

        pointDict["K"]!.head      = pointDict["I"]
        pointDict["K"]!.leftHand  = pointDict["E"]
        pointDict["K"]!.leftFoot  = pointDict["G"]
        pointDict["K"]!.rightHand = pointDict["L"]
        pointDict["K"]!.rightFoot = pointDict["J"]

        pointDict["I"]!.head      = pointDict["D"]
        pointDict["I"]!.leftHand  = pointDict["C"]
        pointDict["I"]!.leftFoot  = pointDict["E"]
        pointDict["I"]!.rightHand = pointDict["K"]
        pointDict["I"]!.rightFoot = pointDict["J"]

        pointDict["D"]!.head      = pointDict["C"]
        pointDict["D"]!.leftHand  = pointDict["I"]
        pointDict["D"]!.leftFoot  = pointDict["J"]
        pointDict["D"]!.rightHand = pointDict["H"]
        pointDict["D"]!.rightFoot = pointDict["B"]
    }
}
