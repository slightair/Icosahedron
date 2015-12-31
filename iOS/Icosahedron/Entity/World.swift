import Foundation
import GameplayKit
import RxSwift

class World {
    enum MarkerStatus {
        case None
        case Red
        case Green
        case Blue
    }

    let icosahedron = Icosahedron()
    var markerStatus: MarkerStatus = .None
    var items: [Item] = []

    var currentPoint = Icosahedron.Point.C {
        didSet {
            let itemPoints = items.map { $0.point }
            if let itemIndex = itemPoints.indexOf(currentPoint) {
                let catchedItem = items[itemIndex]
                items.removeAtIndex(itemIndex)

                switch catchedItem.kind {
                case .Red:
                    markerStatus = .Red
                    redCount += 1
                case .Green:
                    markerStatus = .Green
                    greenCount += 1
                case .Blue:
                    markerStatus = .Blue
                    blueCount += 1
                }
            }
            putNewItemWithIgnore(currentPoint)
            turn += 1

            currentPointChanged.onNext(currentPoint)
        }
    }
    let currentPointChanged = PublishSubject<Icosahedron.Point>()

    var redCount = 0 {
        didSet {
            redCountChanged.onNext(redCount)
        }
    }
    let redCountChanged = PublishSubject<Int>()

    var greenCount = 0 {
        didSet {
            greenCountChanged.onNext(greenCount)
        }
    }
    let greenCountChanged = PublishSubject<Int>()

    var blueCount = 0 {
        didSet {
            blueCountChanged.onNext(blueCount)
        }
    }
    let blueCountChanged = PublishSubject<Int>()

    let pointRandomSource = GKMersenneTwisterRandomSource(seed: 6239)
    let colorRandomSource = GKMersenneTwisterRandomSource(seed: 3962)
    var turn = 0

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
    }

    func putNewItemWithIgnore(ignore: Icosahedron.Point) {
        var candidate = Icosahedron.Point.values
        let ignoreIndex = candidate.indexOf(ignore)
        candidate.removeAtIndex(ignoreIndex!)

        let nextPoint = candidate[pointRandomSource.nextIntWithUpperBound(candidate.count)]
        if !items.contains({ $0.point == nextPoint }) {
            let colors: [Item.Kind] = [.Red, .Green, .Blue]
            let color = colors[colorRandomSource.nextIntWithUpperBound(colors.count)]
            items.append(Item(point: nextPoint, kind: color))
        }
    }

    func itemOfPoint(point: Icosahedron.Point) -> Item? {
        if let index = items.indexOf({ $0.point == point }) {
            return items[index]
        }
        return nil
    }
}
