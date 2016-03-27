import GLKit

class SymbolModel: Renderable {
    static let icons = 4
    static let size: Float = 0.03

    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    var symbol: Symbol

    static func colorForSymbol(symbol: Symbol) -> GLKVector4 {
        let alpha = 0.6
        switch symbol {
        case .RedTriangle, .RedRhombus, .RedSuperTriangle:
            return World.Color.Red.modelColor(CGFloat(alpha))
        case .GreenRhombus, .GreenTriangle, .GreenSuperTriangle:
            return World.Color.Green.modelColor(CGFloat(alpha))
        case .BlueTriangle, .BlueRhombus, .BlueSuperTriangle:
            return World.Color.Blue.modelColor(CGFloat(alpha))
        case .FullColorSuperTriangle:
            return GLKVector4Make(1, 1, 1, Float(alpha))
        }
    }

    static func textureOriginXForSymbol(symbol: Symbol) -> Float {
        switch symbol {
        case .RedTriangle, .GreenTriangle, .BlueTriangle:
            return 0.0
        case .RedRhombus, .GreenRhombus, .BlueRhombus:
            return 1.0 / Float(SymbolModel.icons) * 1
        case .RedSuperTriangle, .GreenSuperTriangle, .BlueSuperTriangle:
            return 1.0 / Float(SymbolModel.icons) * 2
        case .FullColorSuperTriangle:
            return 1.0 / Float(SymbolModel.icons) * 3
        }
    }

    init(symbol: Symbol) {
        self.symbol = symbol

        let normal = GLKVector3Make(0, 0, -1)
        let color = SymbolModel.colorForSymbol(symbol)

        let texOriginX: Float = SymbolModel.textureOriginXForSymbol(symbol)
        let texWidth: Float = 1.0 / Float(SymbolModel.icons)

        let texCoordA = GLKVector2Make(texOriginX, 0)
        let texCoordB = GLKVector2Make(texOriginX, 1)
        let texCoordC = GLKVector2Make(texOriginX + texWidth, 0)
        let texCoordD = GLKVector2Make(texOriginX + texWidth, 1)

        let size = SymbolModel.size
        let posA = GLKVector3Make(-size / 2, -size / 2, 0)
        let posB = GLKVector3Make(-size / 2,  size / 2, 0)
        let posC = GLKVector3Make( size / 2, -size / 2, 0)
        let posD = GLKVector3Make( size / 2,  size / 2, 0)

        localModelVertices = [
            ModelVertex(position: posA, normal: normal, color: color, texCoord: texCoordA),
            ModelVertex(position: posB, normal: normal, color: color, texCoord: texCoordB),
            ModelVertex(position: posC, normal: normal, color: color, texCoord: texCoordC),

            ModelVertex(position: posB, normal: normal, color: color, texCoord: texCoordB),
            ModelVertex(position: posC, normal: normal, color: color, texCoord: texCoordC),
            ModelVertex(position: posD, normal: normal, color: color, texCoord: texCoordD),
        ]
    }
}
