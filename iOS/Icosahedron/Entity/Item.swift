import Foundation

struct Item {
    enum Kind {
        case Stone(color: World.Color)

        static let values: [Kind] = [.Stone(color: .Red), .Stone(color: .Green), .Stone(color: .Blue)]
    }

    let point: Icosahedron.Point
    let kind: Kind
}
