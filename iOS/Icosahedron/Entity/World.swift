import Foundation

class World {
    var items: [Item] = []

    init() {
        let points: [Icosahedron.Point] = [.A, .B, .F, .G, .H]
        for point in points {
            items.append(Item(point: point))
        }
    }
}
