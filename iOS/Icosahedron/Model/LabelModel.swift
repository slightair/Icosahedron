import GLKit
import RxSwift

class LabelModel: Renderable {
    static let defaultBackgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.2).glColor

    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex] = []
    var text: String {
        didSet {
            chars = text.characters.map { FontData.defaultData.map[String($0)]! }
            updateLocalModelVertices()
        }
    }
    var textColor = GLKVector4Make(1, 1, 1, 1)

    var rx_text: AnyObserver<String> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()

            switch event {
            case .Next(let value):
                self?.text = value
            case .Error(let error):
                fatalError("Binding error to UI: \(error)")
                break
            case .Completed:
                break
            }
        }
    }

    var chars: [FontData.Char] = []

    var size: Float = 0.2

    var glyphWidth: Float {
        return size / 10 * FontData.defaultData.ratio
    }

    var glyphHeight: Float {
        return size / 10
    }

    var horizontalAlign: RenderableHorizontalAlign = .Center
    var verticalAlign: RenderableVerticalAlign = .Center
    var showBackground: Bool = false
    var backgroundColor = LabelModel.defaultBackgroundColor
    var backgroundMarginHorizontal: Float = 0.01
    var backgroundMarginVertical: Float = 0.001

    var width: Float {
        return glyphWidth * Float(self.chars.count) + backgroundMarginHorizontal * 2
    }

    let topCoordinate = GLKVector3Make(0.0, 1.0, 0.0)

    init(text: String) {
        self.text = text

        chars = text.characters.map { FontData.defaultData.map[String($0)]! }
        updateLocalModelVertices()
    }

    func updateLocalModelVertices() {
        let normal = GLKVector3Make(0, 0, -1)

        var vertices: [ModelVertex] = []
        var baseX: Float
        let baseY: Float

        switch horizontalAlign {
        case .Left:
            baseX = 0
        case .Center:
            baseX = -glyphWidth * Float(self.chars.count) / 2.0
        case .Right:
            baseX = -glyphWidth * Float(self.chars.count)
        }

        switch verticalAlign {
        case .Top:
            baseY = 0
        case .Center:
            baseY = -glyphHeight / 2.0
        case .Bottom:
            baseY = -glyphHeight
        }

        if showBackground {
            let height = glyphHeight + backgroundMarginVertical * 2

            let posA = GLKVector3Make(baseX - backgroundMarginHorizontal, baseY - backgroundMarginVertical, 0)
            let posB = GLKVector3Make(baseX - backgroundMarginHorizontal, baseY - backgroundMarginVertical + height, 0)
            let posC = GLKVector3Make(baseX - backgroundMarginHorizontal + width, baseY - backgroundMarginVertical, 0)
            let posD = GLKVector3Make(baseX - backgroundMarginHorizontal + width, baseY - backgroundMarginVertical + height, 0)

            let char = FontData.defaultData.map["."]!
            let texCoord = GLKVector2Make(char.rect.s + char.rect.p / 2, char.rect.t + char.rect.q / 2)

            vertices.appendContentsOf([
                ModelVertex(position: posA, normal: normal, color: backgroundColor, texCoord: texCoord),
                ModelVertex(position: posB, normal: normal, color: backgroundColor, texCoord: texCoord),
                ModelVertex(position: posC, normal: normal, color: backgroundColor, texCoord: texCoord),

                ModelVertex(position: posB, normal: normal, color: backgroundColor, texCoord: texCoord),
                ModelVertex(position: posC, normal: normal, color: backgroundColor, texCoord: texCoord),
                ModelVertex(position: posD, normal: normal, color: backgroundColor, texCoord: texCoord),
            ])
        }

        for char in self.chars {
            let localX = glyphWidth * char.canvas.s
            let localY = glyphHeight * char.canvas.t
            let localW = glyphWidth * char.canvas.p
            let localH = glyphHeight * char.canvas.q

            let posA = GLKVector3Make(baseX + localX, baseY + localY, 0)
            let posB = GLKVector3Make(baseX + localX, baseY + localY + localH, 0)
            let posC = GLKVector3Make(baseX + localX + localW, baseY + localY, 0)
            let posD = GLKVector3Make(baseX + localX + localW, baseY + localY + localH, 0)

            let texCoordA = GLKVector2Make(char.rect.s, char.rect.t)
            let texCoordB = GLKVector2Make(char.rect.s, char.rect.t + char.rect.q)
            let texCoordC = GLKVector2Make(char.rect.s + char.rect.p, char.rect.t)
            let texCoordD = GLKVector2Make(char.rect.s + char.rect.p, char.rect.t + char.rect.q)

            vertices.appendContentsOf([
                ModelVertex(position: posA, normal: normal, color: textColor, texCoord: texCoordA),
                ModelVertex(position: posB, normal: normal, color: textColor, texCoord: texCoordB),
                ModelVertex(position: posC, normal: normal, color: textColor, texCoord: texCoordC),

                ModelVertex(position: posB, normal: normal, color: textColor, texCoord: texCoordB),
                ModelVertex(position: posC, normal: normal, color: textColor, texCoord: texCoordC),
                ModelVertex(position: posD, normal: normal, color: textColor, texCoord: texCoordD),
            ])

            baseX += glyphWidth
        }

        localModelVertices = vertices
    }
}
