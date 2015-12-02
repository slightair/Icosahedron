import Foundation
import GameplayKit

class World {
    let icosahedron = Icosahedron()
    var items: [Item] = []
    var roads: [Road] = []
    var currentPoint = Icosahedron.Point.C {
        didSet {
            let itemPoints = items.map { $0.point }
            if let itemIndex = itemPoints.indexOf(currentPoint) {
                let catchedItem = items[itemIndex]
                items.removeAtIndex(itemIndex)

                print(catchedItem.kind)
            }
            putNewItemWithIgnore(currentPoint)
        }
    }
    let randomSource = GKMersenneTwisterRandomSource(seed: 6239)

    init() {
        items = [
            Item(point: .A, kind: .Red),
            Item(point: .B, kind: .Green),
            Item(point: .D, kind: .Red),
            Item(point: .E, kind: .Green),
            Item(point: .F, kind: .Blue),
            Item(point: .G, kind: .Red),
            Item(point: .H, kind: .Green),
            Item(point: .I, kind: .Blue),
            Item(point: .J, kind: .Red),
            Item(point: .K, kind: .Green),
            Item(point: .L, kind: .Blue),
        ]

        roads = [
            Road(side: .AB, kind: .Red),
            Road(side: .AC, kind: .Green),
            Road(side: .AE, kind: .Blue),
            Road(side: .AF, kind: .Red),
            Road(side: .AG, kind: .Green),
            Road(side: .BC, kind: .Blue),
            Road(side: .BD, kind: .Red),
            Road(side: .BF, kind: .Green),
            Road(side: .BH, kind: .Blue),
            Road(side: .CD, kind: .Red),
            Road(side: .CE, kind: .Green),
            Road(side: .CI, kind: .Blue),
            Road(side: .DH, kind: .Red),
            Road(side: .DI, kind: .Green),
            Road(side: .DJ, kind: .Blue),
            Road(side: .EI, kind: .Red),
            Road(side: .EK, kind: .Green),
            Road(side: .FG, kind: .Blue),
            Road(side: .FH, kind: .Red),
            Road(side: .FL, kind: .Green),
            Road(side: .GE, kind: .Blue),
            Road(side: .GK, kind: .Red),
            Road(side: .GL, kind: .Green),
            Road(side: .HJ, kind: .Blue),
            Road(side: .HL, kind: .Red),
            Road(side: .IJ, kind: .Green),
            Road(side: .IK, kind: .Blue),
            Road(side: .JK, kind: .Red),
            Road(side: .JL, kind: .Green),
            Road(side: .KL, kind: .Blue),
        ]
    }

    func putNewItemWithIgnore(ignore: Icosahedron.Point) {
        var candidate = Icosahedron.Point.values
        let ignoreIndex = candidate.indexOf(ignore)
        candidate.removeAtIndex(ignoreIndex!)

        let nextPoint = candidate[randomSource.nextIntWithUpperBound(candidate.count)]
        if !items.contains({ $0.point == nextPoint }) {
            items.append(Item(point: nextPoint, kind: .Green))
        }
    }
}
