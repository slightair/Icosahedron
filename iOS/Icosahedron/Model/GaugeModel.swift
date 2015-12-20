import GLKit

class GaugeModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex] {
        let normal = GLKVector3Make(0, 0, -1)
        let progressColor = baseColor
        let maxColor = GLKVector4Subtract(baseColor, GLKVector4Make(0, 0, 0, 0.5))
        let texCoord = GLKVector2Make(0, 0)

        let posA = GLKVector3Make(-width / 2, -height / 2, 0)
        let posB = GLKVector3Make(-width / 2,  height / 2, 0)
        let posC = GLKVector3Make(-width / 2 + width * progress, -height / 2, 0)
        let posD = GLKVector3Make(-width / 2 + width * progress,  height / 2, 0)
        let posE = GLKVector3Make(width / 2, -height / 2, 0)
        let posF = GLKVector3Make(width / 2,  height / 2, 0)

        return [
            ModelVertex(position: posA, normal: normal, color: progressColor, texCoord: texCoord),
            ModelVertex(position: posB, normal: normal, color: progressColor, texCoord: texCoord),
            ModelVertex(position: posC, normal: normal, color: progressColor, texCoord: texCoord),

            ModelVertex(position: posB, normal: normal, color: progressColor, texCoord: texCoord),
            ModelVertex(position: posC, normal: normal, color: progressColor, texCoord: texCoord),
            ModelVertex(position: posD, normal: normal, color: progressColor, texCoord: texCoord),

            ModelVertex(position: posC, normal: normal, color: maxColor, texCoord: texCoord),
            ModelVertex(position: posD, normal: normal, color: maxColor, texCoord: texCoord),
            ModelVertex(position: posE, normal: normal, color: maxColor, texCoord: texCoord),

            ModelVertex(position: posD, normal: normal, color: maxColor, texCoord: texCoord),
            ModelVertex(position: posE, normal: normal, color: maxColor, texCoord: texCoord),
            ModelVertex(position: posF, normal: normal, color: maxColor, texCoord: texCoord),
        ]
    }
    var customColor: GLKVector4? = nil

    let baseColor: GLKVector4
    var progress: Float = 0.5
    var width: Float = 0.3
    let height: Float = 0.02

    init(color: GLKVector4) {
        baseColor = color
    }
}
