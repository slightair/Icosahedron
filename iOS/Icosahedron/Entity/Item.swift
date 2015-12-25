import Foundation

struct Item {
    enum Kind {
        case Red
        case Green
        case Blue
        case Magenta
    }

    let point: Icosahedron.Point
    let kind: Kind
}
