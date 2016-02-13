import Foundation

struct Track: CustomStringConvertible {
    let start: Icosahedron.Point
    let end: Icosahedron.Point
    let color: World.Color

    var description: String {
        return "\(start) -[\(color)]-> \(end)"
    }
}
