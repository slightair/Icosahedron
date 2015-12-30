import GLKit
import Himotoki

class FontData {
    struct Char: Decodable {
        let canvas: GLKVector4
        let rect: GLKVector4

        static func decode(e: Extractor) throws -> Char {
            let canvas: [Float] = try e <|| "canvas"
            let rect: [Float] = try e <|| "rect"

            return Char(
                canvas: GLKVector4Make(canvas[0], canvas[1], canvas[2], canvas[3]),
                rect: GLKVector4Make(rect[0], rect[1], rect[2], rect[3])
            )
        }
    }

    let name: String
    let map: [String: Char]
    let ratio: Float
    var textureInfo: GLKTextureInfo!

    init(name: String) {
        self.name = name
        guard let mapAsset = NSDataAsset(name: "\(name)Map") else {
            fatalError("map file not found")
        }
        guard let JSONObject = try! NSJSONSerialization.JSONObjectWithData(mapAsset.data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] else {
            fatalError("invalid json file")
        }
        ratio = Float(JSONObject["ratio"] as! NSNumber)
        map = FontData.parseMapFile(JSONObject)
    }

    static func parseMapFile(object: [String: AnyObject]) -> [String: Char] {
        guard let chars: [String: Char] = try! decodeDictionary(object["chars"]!) else {
            fatalError("parse error")
        }
        return chars
    }

    func loadTexture() {
        guard let asset = NSDataAsset(name: name) else {
            fatalError("texture file not found")
        }
        textureInfo = try! GLKTextureLoader.textureWithContentsOfData(asset.data, options: nil)
    }

    static let defaultData = FontData(name: "Font")
}
