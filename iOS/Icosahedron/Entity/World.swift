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
            Road(side: .AB),
            Road(side: .AC),
            Road(side: .AE),
            Road(side: .AF),
            Road(side: .AG),
            Road(side: .BC),
            Road(side: .BD),
            Road(side: .BF),
            Road(side: .BH),
            Road(side: .CD),
            Road(side: .CE),
            Road(side: .CI),
            Road(side: .DH),
            Road(side: .DI),
            Road(side: .DJ),
            Road(side: .EI),
            Road(side: .EK),
            Road(side: .FG),
            Road(side: .FH),
            Road(side: .FL),
            Road(side: .GE),
            Road(side: .GK),
            Road(side: .GL),
            Road(side: .HJ),
            Road(side: .HL),
            Road(side: .IJ),
            Road(side: .IK),
            Road(side: .JK),
            Road(side: .JL),
            Road(side: .KL),
        ]
    }
}
