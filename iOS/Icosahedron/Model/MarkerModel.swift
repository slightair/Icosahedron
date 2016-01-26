import GLKit
import Chameleon

class MarkerModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    var scale = GLKVector3Make(1.0, 1.0, 1.0)
    var customColor: GLKVector4? = nil
    var status: World.MarkerStatus = .Neutral {
        didSet {
            customColor = MarkerModel.colorOfStatus(status)
        }
    }

    let topCoordinate: GLKVector3
    let tailCoordinate: GLKVector3

    static func colorOfStatus(status: World.MarkerStatus) -> GLKVector4 {
        switch status {
        case .Marked(let color):
            return color.modelColor()
        case .Neutral:
            return UIColor.flatSandColor().glColor
        }
    }

    init() {
        let scale: Float = 0.02
        let faceColor = MarkerModel.colorOfStatus(.Neutral)

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

        let texCoord = GLKVector2Make(0, 0)

        localModelVertices = [
            ModelVertex(position: coordC, normal: normalCGA, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordG, normal: normalCGA, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordA, normal: normalCGA, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordE, normal: normalEGC, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordG, normal: normalEGC, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalEGC, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordH, normal: normalHGE, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordG, normal: normalHGE, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordE, normal: normalHGE, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordF, normal: normalFHE, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordH, normal: normalFHE, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordE, normal: normalFHE, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordB, normal: normalBHD, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordH, normal: normalBHD, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalBHD, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordD, normal: normalDHF, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordH, normal: normalDHF, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordF, normal: normalDHF, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordB, normal: normalBAG, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordA, normal: normalBAG, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordG, normal: normalBAG, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordH, normal: normalHBG, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalHBG, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordG, normal: normalHBG, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordB, normal: normalBCA, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalBCA, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordA, normal: normalBCA, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordD, normal: normalDCB, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalDCB, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordB, normal: normalDCB, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordD, normal: normalDEC, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordE, normal: normalDEC, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordC, normal: normalDEC, color: faceColor, texCoord: texCoord),

            ModelVertex(position: coordF, normal: normalFED, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordE, normal: normalFED, color: faceColor, texCoord: texCoord),
            ModelVertex(position: coordD, normal: normalFED, color: faceColor, texCoord: texCoord),
        ]

        topCoordinate = GLKVector3Make(0, 1, 0)
        tailCoordinate = GLKVector3Make(-1, 0, 0)
    }

    func setPosition(newPosition: GLKVector3, prevPosition: GLKVector3) {
        position = newPosition

        let dotProduct = GLKVector3DotProduct(GLKVector3Normalize(newPosition), GLKVector3Normalize(newPosition))
        let k = GLKVector3Length(newPosition) / (GLKVector3Length(prevPosition) * dotProduct)
        let tailDestination = GLKVector3Subtract(GLKVector3MultiplyScalar(prevPosition, k), newPosition)

        let adjustTopQuaternion = quaternionForRotate(from: topCoordinate, to: newPosition)
        let newTailCoordinate = GLKQuaternionRotateVector3(adjustTopQuaternion, tailCoordinate)
        let desiredTailCoordinate = GLKVector3CrossProduct(GLKVector3CrossProduct(newPosition, tailDestination), newPosition)
        let adjustTailQuaternion = quaternionForRotate(from: newTailCoordinate, to: desiredTailCoordinate)
        quaternion = GLKQuaternionMultiply(adjustTailQuaternion, adjustTopQuaternion)
    }
}
