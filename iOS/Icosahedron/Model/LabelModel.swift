import GLKit

class LabelModel: Renderable {
    enum HorizontalAlign {
        case Left
        case Center
        case Right
    }

    enum VerticalAlign {
        case Top
        case Center
        case Bottom
    }

    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex] {
        let normal = GLKVector3Make(0, 0, -1)
        let color = GLKVector4Make(1, 1, 1, 1)

        let glyphWidth = size / 10 * FontData.defaultData.ratio
        let glyphHeight = size / 10
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
                ModelVertex(position: posA, normal: normal, color: color, texCoord: texCoordA),
                ModelVertex(position: posB, normal: normal, color: color, texCoord: texCoordB),
                ModelVertex(position: posC, normal: normal, color: color, texCoord: texCoordC),

                ModelVertex(position: posB, normal: normal, color: color, texCoord: texCoordB),
                ModelVertex(position: posC, normal: normal, color: color, texCoord: texCoordC),
                ModelVertex(position: posD, normal: normal, color: color, texCoord: texCoordD),
            ])

            baseX += glyphWidth
        }
        return vertices
    }
    var customColor: GLKVector4? = nil
    var text: String {
        didSet {
            chars = text.characters.map { FontData.defaultData.map[String($0)]! }
        }
    }
    var chars: [FontData.Char] = []

    var size: Float = 0.2

    var horizontalAlign: HorizontalAlign = .Center
    var verticalAlign: VerticalAlign = .Center

    class var scale: Float {
        return 1.0
    }

    let topCoordinate = GLKVector3Make(0.0, 1.0, 0.0)

    init(text: String) {
        self.text = text
        chars = text.characters.map { FontData.defaultData.map[String($0)]! }
    }
}