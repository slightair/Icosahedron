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
            Road(left: .A, right: .C),
            Road(left: .A, right: .E),
            Road(left: .A, right: .F),
            Road(left: .A, right: .G),
            Road(left: .B, right: .C),
            Road(left: .B, right: .D),
            Road(left: .B, right: .F),
            Road(left: .B, right: .H),
            Road(left: .C, right: .D),
            Road(left: .C, right: .E),
            Road(left: .C, right: .I),
            Road(left: .D, right: .H),
            Road(left: .D, right: .I),
            Road(left: .D, right: .J),
            Road(left: .G, right: .E), // workaround
            Road(left: .E, right: .I),
            Road(left: .E, right: .K),
            Road(left: .F, right: .G),
            Road(left: .F, right: .H),
            Road(left: .F, right: .L),
            Road(left: .G, right: .K),
            Road(left: .G, right: .L),
            Road(left: .H, right: .J),
            Road(left: .H, right: .L),
            Road(left: .I, right: .J),
            Road(left: .I, right: .K),
            Road(left: .J, right: .K),
            Road(left: .J, right: .L),
            Road(left: .K, right: .L),
        ]
    }
}
