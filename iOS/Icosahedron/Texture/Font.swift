import GLKit
import Himotoki

class Font {
    struct Char: Decodable {
        let offset: GLKVector2
        let rect: GLKVector4

        static func decode(e: Extractor) throws -> Char {
            let offset: [Float] = try e <|| "offset"
            let rect: [Float] = try e <|| "rect"

            return Char(
                offset: GLKVector2Make(offset[0], offset[1]),
                rect: GLKVector4Make(rect[0], rect[1], rect[2], rect[3])
            )
        }
    }

    let map: [String: Char]

    init(name: String) {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: "json") else {
            fatalError("file not found \(name).json")
        }

        let data = NSData(contentsOfFile: path)
        guard let JSONObject = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] else {
            fatalError("invalid json file")
        }
        map = Font.parseMapFile(JSONObject)
    }

    static func parseMapFile(object: [String: AnyObject]) -> [String: Char] {
        guard let chars: [String: Char] = try! decodeDictionary(object["chars"]!) else {
            fatalError("parse error")
        }
        return chars
    }

    static let Default = Font(name: "font")
}
