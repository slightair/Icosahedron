import Foundation

class World {
    let icosahedron = Icosahedron()
    var items: [Item] = []
    var currentPoint = Icosahedron.Point.C

    init() {
        let points: [Icosahedron.Point] = [.A, .B, .F, .G, .H]
        for point in points {
            items.append(Item(point: point))
        }
    }
}
