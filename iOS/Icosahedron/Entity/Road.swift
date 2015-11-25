import Foundation

struct Road {
    enum Kind {
        case Red
        case Green
        case Blue
    }

    let left: Icosahedron.Point
    let right: Icosahedron.Point
    let kind: Kind

    init(side: Icosahedron.Side, kind: Kind) {
        self.left = Icosahedron.Point(rawValue: side.rawValue.substringToIndex(side.rawValue.startIndex.advancedBy(1)))!
        self.right = Icosahedron.Point(rawValue: side.rawValue.substringFromIndex(side.rawValue.startIndex.advancedBy(1)))!
        self.kind = kind
    }
}
