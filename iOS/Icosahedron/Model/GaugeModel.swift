import GLKit
import RxSwift

class GaugeModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex] {
        let normal = GLKVector3Make(0, 0, -1)
        let texCoord = GLKVector2Make(0, 0)

        let progressColor = baseColor
        let maxColor = GLKVector4Subtract(baseColor, GLKVector4Make(0, 0, 0, 0.7))

        let leftColor = (direction == .LeftToRight) ? progressColor : maxColor
        let rightColor = (direction == .LeftToRight) ? maxColor : progressColor

        let baseX: Float
        let baseY: Float

        switch horizontalAlign {
        case .Left:
            baseX = width / 2
        case .Center:
            baseX = 0
        case .Right:
            baseX = -width / 2
        }

        switch verticalAlign {
        case .Top:
            baseY = height / 2
        case .Center:
            baseY = 0
        case .Bottom:
            baseY = -height / 2
        }

        let border = width * ((direction == .LeftToRight) ? progress : 1.0 - progress)

        let posA = GLKVector3Make(baseX + -width / 2, baseY + -height / 2, 0)
        let posB = GLKVector3Make(baseX + -width / 2, baseY +  height / 2, 0)
        let posC = GLKVector3Make(baseX + -width / 2 + border, baseY + -height / 2, 0)
        let posD = GLKVector3Make(baseX + -width / 2 + border, baseY +  height / 2, 0)
        let posE = GLKVector3Make(baseX + width / 2, baseY + -height / 2, 0)
        let posF = GLKVector3Make(baseX + width / 2, baseY +  height / 2, 0)

        return [
            ModelVertex(position: posA, normal: normal, color: leftColor, texCoord: texCoord),
            ModelVertex(position: posB, normal: normal, color: leftColor, texCoord: texCoord),
            ModelVertex(position: posC, normal: normal, color: leftColor, texCoord: texCoord),

            ModelVertex(position: posB, normal: normal, color: leftColor, texCoord: texCoord),
            ModelVertex(position: posC, normal: normal, color: leftColor, texCoord: texCoord),
            ModelVertex(position: posD, normal: normal, color: leftColor, texCoord: texCoord),

            ModelVertex(position: posC, normal: normal, color: rightColor, texCoord: texCoord),
            ModelVertex(position: posD, normal: normal, color: rightColor, texCoord: texCoord),
            ModelVertex(position: posE, normal: normal, color: rightColor, texCoord: texCoord),

            ModelVertex(position: posD, normal: normal, color: rightColor, texCoord: texCoord),
            ModelVertex(position: posE, normal: normal, color: rightColor, texCoord: texCoord),
            ModelVertex(position: posF, normal: normal, color: rightColor, texCoord: texCoord),
        ]
    }
    var customColor: GLKVector4? = nil

    let baseColor: GLKVector4

    var progress: Float = 0.0 {
        didSet {
            progress = min(1.0, max(0.0, progress))
        }
    }

    var rx_progress: AnyObserver<Float> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()

            switch event {
            case .Next(let value):
                self?.progress = value
            case .Error(let error):
                fatalError("Binding error to UI: \(error)")
                break
            case .Completed:
                break
            }
        }
    }

    var width: Float = 0.12
    let height: Float = 0.0075
    var horizontalAlign: RenderableHorizontalAlign = .Center
    var verticalAlign: RenderableVerticalAlign = .Center
    var direction: RenderableDirection = .LeftToRight

    init(color: GLKVector4) {
        baseColor = color
    }
}
