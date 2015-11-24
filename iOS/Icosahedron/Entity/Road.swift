import Foundation

struct Road {
    let left: Icosahedron.Point
    let right: Icosahedron.Point

    init(side: Icosahedron.Side) {
        left = Icosahedron.Point(rawValue: side.rawValue.substringToIndex(side.rawValue.startIndex.advancedBy(1)))!
        right = Icosahedron.Point(rawValue: side.rawValue.substringFromIndex(side.rawValue.startIndex.advancedBy(1)))!
    }
}
