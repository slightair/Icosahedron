import Foundation

func == (lhs: Item.Kind, rhs: Item.Kind) -> Bool {
    switch (lhs, rhs) {
    case (.Stone(let l), .Stone(let r)) where l == r:
        return true
    default:
        return false
    }
}

struct Item {
    enum Kind {
        case Stone(color: World.Color)

        static let values: [Kind] = [.Stone(color: .Red), .Stone(color: .Green), .Stone(color: .Blue)]
    }

    let point: Icosahedron.Point
    let kind: Kind
}
