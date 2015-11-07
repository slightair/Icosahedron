import GLKit

func quaternionForRotate(from: IcosahedronVertex, to: IcosahedronVertex ) -> GLKQuaternion {
    let normalizedFrom = GLKVector3Normalize(from.coordinate)
    let normalizedTo = GLKVector3Normalize(to.coordinate)

    let cosineTheta = GLKVector3DotProduct(normalizedFrom, normalizedTo)
    let rotationAxis = GLKVector3CrossProduct(normalizedFrom, normalizedTo)

    let s = sqrtf((1 + cosineTheta) * 2)
    let inverse = 1 / s

    return GLKQuaternionMakeWithVector3(GLKVector3MultiplyScalar(rotationAxis, inverse), s * 0.5)
}

struct IcosahedronModel {
    static let NumberOfPointVertices = 12
    static let NumberOfLineVertices = 30 * 2

    var pointVertices: [ModelVertex]
    var lineVertices: [ModelVertex]
    var vertices: [String: IcosahedronVertex] = [:]

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

        let colorA = GLKVector4Make(0.902, 0.0,   0.071, 1.0)
        let colorB = GLKVector4Make(0.953, 0.596, 0.0,   1.0)
        let colorC = GLKVector4Make(1.0,   0.945, 0.0,   1.0)
        let colorD = GLKVector4Make(0.561, 0.765, 0.122, 1.0)
        let colorE = GLKVector4Make(0.0,   0.6,   0.267, 1.0)
        let colorF = GLKVector4Make(0.0,   0.62,  0.588, 1.0)
        let colorG = GLKVector4Make(0.0,   0.627, 0.914, 1.0)
        let colorH = GLKVector4Make(0.0,   0.408, 0.718, 1.0)
        let colorI = GLKVector4Make(0.114, 0.125, 0.533, 1.0)
        let colorJ = GLKVector4Make(0.573, 0.027, 0.514, 1.0)
        let colorK = GLKVector4Make(0.894, 0.0,   0.498, 1.0)
        let colorL = GLKVector4Make(0.898, 0.0,   0.31,  1.0)

        let lineColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)

        pointVertices = [
            ModelVertex(position: coordA, normal: coordA, color: colorA),
            ModelVertex(position: coordB, normal: coordB, color: colorB),
            ModelVertex(position: coordC, normal: coordC, color: colorC),
            ModelVertex(position: coordD, normal: coordD, color: colorD),
            ModelVertex(position: coordE, normal: coordE, color: colorE),
            ModelVertex(position: coordF, normal: coordF, color: colorF),
            ModelVertex(position: coordG, normal: coordG, color: colorG),
            ModelVertex(position: coordH, normal: coordH, color: colorH),
            ModelVertex(position: coordI, normal: coordI, color: colorI),
            ModelVertex(position: coordJ, normal: coordJ, color: colorJ),
            ModelVertex(position: coordK, normal: coordK, color: colorK),
            ModelVertex(position: coordL, normal: coordL, color: colorL),
        ]

        lineVertices = [
            ModelVertex(position: coordA, normal: coordA, color: lineColor), ModelVertex(position: coordB, normal: coordB, color: lineColor),
            ModelVertex(position: coordA, normal: coordA, color: lineColor), ModelVertex(position: coordC, normal: coordC, color: lineColor),
            ModelVertex(position: coordA, normal: coordA, color: lineColor), ModelVertex(position: coordE, normal: coordE, color: lineColor),
            ModelVertex(position: coordA, normal: coordA, color: lineColor), ModelVertex(position: coordF, normal: coordF, color: lineColor),
            ModelVertex(position: coordA, normal: coordA, color: lineColor), ModelVertex(position: coordG, normal: coordG, color: lineColor),
            ModelVertex(position: coordB, normal: coordB, color: lineColor), ModelVertex(position: coordC, normal: coordC, color: lineColor),
            ModelVertex(position: coordB, normal: coordB, color: lineColor), ModelVertex(position: coordD, normal: coordD, color: lineColor),
            ModelVertex(position: coordB, normal: coordB, color: lineColor), ModelVertex(position: coordF, normal: coordF, color: lineColor),
            ModelVertex(position: coordB, normal: coordB, color: lineColor), ModelVertex(position: coordH, normal: coordH, color: lineColor),
            ModelVertex(position: coordC, normal: coordC, color: lineColor), ModelVertex(position: coordD, normal: coordD, color: lineColor),
            ModelVertex(position: coordC, normal: coordC, color: lineColor), ModelVertex(position: coordE, normal: coordE, color: lineColor),
            ModelVertex(position: coordC, normal: coordC, color: lineColor), ModelVertex(position: coordI, normal: coordI, color: lineColor),
            ModelVertex(position: coordD, normal: coordD, color: lineColor), ModelVertex(position: coordH, normal: coordH, color: lineColor),
            ModelVertex(position: coordD, normal: coordD, color: lineColor), ModelVertex(position: coordI, normal: coordI, color: lineColor),
            ModelVertex(position: coordD, normal: coordD, color: lineColor), ModelVertex(position: coordJ, normal: coordJ, color: lineColor),
            ModelVertex(position: coordE, normal: coordE, color: lineColor), ModelVertex(position: coordG, normal: coordG, color: lineColor),
            ModelVertex(position: coordE, normal: coordE, color: lineColor), ModelVertex(position: coordI, normal: coordI, color: lineColor),
            ModelVertex(position: coordE, normal: coordE, color: lineColor), ModelVertex(position: coordK, normal: coordK, color: lineColor),
            ModelVertex(position: coordF, normal: coordF, color: lineColor), ModelVertex(position: coordG, normal: coordG, color: lineColor),
            ModelVertex(position: coordF, normal: coordF, color: lineColor), ModelVertex(position: coordH, normal: coordH, color: lineColor),
            ModelVertex(position: coordF, normal: coordF, color: lineColor), ModelVertex(position: coordL, normal: coordL, color: lineColor),
            ModelVertex(position: coordG, normal: coordG, color: lineColor), ModelVertex(position: coordK, normal: coordK, color: lineColor),
            ModelVertex(position: coordG, normal: coordG, color: lineColor), ModelVertex(position: coordL, normal: coordL, color: lineColor),
            ModelVertex(position: coordH, normal: coordH, color: lineColor), ModelVertex(position: coordJ, normal: coordJ, color: lineColor),
            ModelVertex(position: coordH, normal: coordH, color: lineColor), ModelVertex(position: coordL, normal: coordL, color: lineColor),
            ModelVertex(position: coordI, normal: coordI, color: lineColor), ModelVertex(position: coordJ, normal: coordJ, color: lineColor),
            ModelVertex(position: coordI, normal: coordI, color: lineColor), ModelVertex(position: coordK, normal: coordK, color: lineColor),
            ModelVertex(position: coordJ, normal: coordJ, color: lineColor), ModelVertex(position: coordK, normal: coordK, color: lineColor),
            ModelVertex(position: coordJ, normal: coordJ, color: lineColor), ModelVertex(position: coordL, normal: coordL, color: lineColor),
            ModelVertex(position: coordK, normal: coordK, color: lineColor), ModelVertex(position: coordL, normal: coordL, color: lineColor),
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
            vertices[point.name] = point
        }

        vertices["C"]!.head      = vertices["I"]
        vertices["C"]!.leftHand  = vertices["D"]
        vertices["C"]!.leftFoot  = vertices["B"]
        vertices["C"]!.rightHand = vertices["E"]
        vertices["C"]!.rightFoot = vertices["A"]

        vertices["B"]!.head      = vertices["A"]
        vertices["B"]!.leftHand  = vertices["C"]
        vertices["B"]!.leftFoot  = vertices["D"]
        vertices["B"]!.rightHand = vertices["H"]
        vertices["B"]!.rightFoot = vertices["F"]

        vertices["A"]!.head      = vertices["E"]
        vertices["A"]!.leftHand  = vertices["C"]
        vertices["A"]!.leftFoot  = vertices["B"]
        vertices["A"]!.rightHand = vertices["F"]
        vertices["A"]!.rightFoot = vertices["G"]

        vertices["E"]!.head      = vertices["G"]
        vertices["E"]!.leftHand  = vertices["K"]
        vertices["E"]!.leftFoot  = vertices["I"]
        vertices["E"]!.rightHand = vertices["C"]
        vertices["E"]!.rightFoot = vertices["A"]

        vertices["G"]!.head      = vertices["L"]
        vertices["G"]!.leftHand  = vertices["K"]
        vertices["G"]!.leftFoot  = vertices["E"]
        vertices["G"]!.rightHand = vertices["A"]
        vertices["G"]!.rightFoot = vertices["F"]

        vertices["L"]!.head      = vertices["F"]
        vertices["L"]!.leftHand  = vertices["H"]
        vertices["L"]!.leftFoot  = vertices["J"]
        vertices["L"]!.rightHand = vertices["K"]
        vertices["L"]!.rightFoot = vertices["G"]

        vertices["F"]!.head      = vertices["H"]
        vertices["F"]!.leftHand  = vertices["L"]
        vertices["F"]!.leftFoot  = vertices["G"]
        vertices["F"]!.rightHand = vertices["A"]
        vertices["F"]!.rightFoot = vertices["B"]

        vertices["H"]!.head      = vertices["J"]
        vertices["H"]!.leftHand  = vertices["L"]
        vertices["H"]!.leftFoot  = vertices["F"]
        vertices["H"]!.rightHand = vertices["B"]
        vertices["H"]!.rightFoot = vertices["D"]

        vertices["J"]!.head      = vertices["K"]
        vertices["J"]!.leftHand  = vertices["L"]
        vertices["J"]!.leftFoot  = vertices["H"]
        vertices["J"]!.rightHand = vertices["D"]
        vertices["J"]!.rightFoot = vertices["I"]

        vertices["K"]!.head      = vertices["I"]
        vertices["K"]!.leftHand  = vertices["E"]
        vertices["K"]!.leftFoot  = vertices["G"]
        vertices["K"]!.rightHand = vertices["L"]
        vertices["K"]!.rightFoot = vertices["J"]

        vertices["I"]!.head      = vertices["D"]
        vertices["I"]!.leftHand  = vertices["C"]
        vertices["I"]!.leftFoot  = vertices["E"]
        vertices["I"]!.rightHand = vertices["K"]
        vertices["I"]!.rightFoot = vertices["J"]

        vertices["D"]!.head      = vertices["C"]
        vertices["D"]!.leftHand  = vertices["I"]
        vertices["D"]!.leftFoot  = vertices["J"]
        vertices["D"]!.rightHand = vertices["H"]
        vertices["D"]!.rightFoot = vertices["B"]
    }
}
