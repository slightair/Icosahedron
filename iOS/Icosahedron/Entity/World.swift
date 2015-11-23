import Foundation

class World {
    let icosahedron = Icosahedron()
    var items: [Item] = []
    var roads: [Road] = []
    var currentPoint = Icosahedron.Point.C

    init() {
        let points: [Icosahedron.Point] = [.A, .B, .F, .G, .H]
        for point in points {
            items.append(Item(point: point))
        }

        roads = [
            Road(left: .A, right: .B),
            Road(left: .B, right: .C),
            Road(left: .F, right: .G),
        ]
    }
}
