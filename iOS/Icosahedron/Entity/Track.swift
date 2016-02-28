import Foundation

struct Track: CustomStringConvertible {
    let start: Icosahedron.Point
    let end: Icosahedron.Point
    let color: World.Color
    let turn: Int

    var description: String {
        return "\(start) -[\(color)](\(turn))-> \(end)"
    }
}
