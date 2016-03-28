import GLKit

class TextureSet {
    static let sharedSet = TextureSet()

    enum TextureName: String {
        case Debug = "Debug"
        case White = "White"
        case BackgroundMesh = "BackgroundMesh"
        case Point = "Point"
        case SymbolIcon = "SymbolIcon"
        case IcosahedronMesh = "IcosahedronMesh"

        static let values: [TextureName] = [.Debug, .White, .BackgroundMesh, .Point, .SymbolIcon, .IcosahedronMesh]
    }

    private var textures: [String: GLKTextureInfo] = [:]

    func loadTextures() {
        for name in TextureName.values {
            guard let textureAsset = NSDataAsset(name: name.rawValue) else {
                fatalError("\(name.rawValue) texture file not found")
            }
            let textureInfo = try! GLKTextureLoader.textureWithContentsOfData(textureAsset.data, options: nil)
            textures[name.rawValue] = textureInfo
        }
    }

    subscript(name: TextureName) -> GLKTextureInfo {
        get {
            return textures[name.rawValue]!
        }
    }
}
