import GLKit

class LabelModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex] {
        let normal = GLKVector3Make(0, 0, -1)
        let color = GLKVector4Make(1, 1, 1, 1)

        let glyphWidth = size / 10 * Font.Default.ratio
        let glyphHeight = size / 10
        var vertices: [ModelVertex] = []
        var baseX: Float = 0.0
        for char in self.chars {
            let localX = glyphWidth * char.canvas.s
            let localY = glyphHeight * char.canvas.t
            let localW = glyphWidth * char.canvas.p
            let localH = glyphHeight * char.canvas.q

            let posA = GLKVector3Make(baseX + localX, localY, 0)
            let posB = GLKVector3Make(baseX + localX, localY + localH, 0)
            let posC = GLKVector3Make(baseX + localX + localW, localY, 0)
            let posD = GLKVector3Make(baseX + localX + localW, localY + localH, 0)

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
            chars = text.characters.map { Font.Default.map[String($0)]! }
        }
    }
    var chars: [Font.Char] = []

    var size: Float = 0.2

    class var scale: Float {
        return 1.0
    }

    let topCoordinate = GLKVector3Make(0.0, 1.0, 0.0)

    init(text: String) {
        self.text = text
        chars = text.characters.map { Font.Default.map[String($0)]! }
    }
}