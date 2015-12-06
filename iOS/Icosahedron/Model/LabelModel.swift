import GLKit

class LabelModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex] {
        let normal = GLKVector3Make(0, 0, -1)
        let color = GLKVector4Make(1, 1, 1, 1)

        let glyphWidth = glyphSize * (30.0 / 63.0) // tentative
        let glyphHeight = glyphSize
        var vertices: [ModelVertex] = []
        var posX: Float = 0.0
        for char in self.chars {
            let posA = GLKVector3Make(posX, 0, 0)
            let posB = GLKVector3Make(posX, glyphHeight, 0)
            let posC = GLKVector3Make(posX + glyphWidth, 0, 0)
            let posD = GLKVector3Make(posX + glyphWidth, glyphHeight, 0)

            vertices.appendContentsOf([
                ModelVertex(position: posA, normal: normal, color: GLKVector4Make(1, 0, 0, 0), texCoord: GLKVector2Make(0, 0)),
                ModelVertex(position: posB, normal: normal, color: color, texCoord: GLKVector2Make(0, 1)),
                ModelVertex(position: posC, normal: normal, color: color, texCoord: GLKVector2Make(1, 0)),

                ModelVertex(position: posB, normal: normal, color: color, texCoord: GLKVector2Make(0, 1)),
                ModelVertex(position: posC, normal: normal, color: color, texCoord: GLKVector2Make(1, 0)),
                ModelVertex(position: posD, normal: normal, color: color, texCoord: GLKVector2Make(1, 1)),
            ])

            posX += glyphWidth
        }
        return vertices
    }
    var customColor: GLKVector4? = nil
    let text: String
    let chars: [Font.Char]

    let glyphSize: Float = 0.2

    class var scale: Float {
        return 1.0
    }

    let topCoordinate = GLKVector3Make(0.0, 1.0, 0.0)

    init(text: String) {
        self.text = text
        self.chars = text.characters.map { Font.Default.map[String($0)]! }
    }
}