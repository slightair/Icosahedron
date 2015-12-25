import Foundation
import GameplayKit
import RxSwift

class World {
    enum MarkerStatus {
        case None
        case Red
        case Green
        case Blue
        case Magenta
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
                case .Magenta:
                    markerStatus = .Magenta
                    magentaCount += 1
                }
            }
            putNewItemWithIgnore(currentPoint)
            moveCount += 1

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

    var magentaCount = 0 {
        didSet {
            magentaCountChanged.onNext(magentaCount)
        }
    }
    let magentaCountChanged = PublishSubject<Int>()

    let pointRandomSource = GKMersenneTwisterRandomSource(seed: 6239)
    let colorRandomSource = GKMersenneTwisterRandomSource(seed: 3962)
    var moveCount = 0

    init() {
        items = [
            Item(point: .A, kind: .Red),
            Item(point: .B, kind: .Green),
            Item(point: .D, kind: .Magenta),
            Item(point: .E, kind: .Red),
            Item(point: .F, kind: .Green),
            Item(point: .G, kind: .Blue),
            Item(point: .H, kind: .Magenta),
            Item(point: .I, kind: .Red),
            Item(point: .J, kind: .Green),
            Item(point: .K, kind: .Blue),
            Item(point: .L, kind: .Magenta),
        ]
    }

    func putNewItemWithIgnore(ignore: Icosahedron.Point) {
        var candidate = Icosahedron.Point.values
        let ignoreIndex = candidate.indexOf(ignore)
        candidate.removeAtIndex(ignoreIndex!)

        let nextPoint = candidate[pointRandomSource.nextIntWithUpperBound(candidate.count)]
        if !items.contains({ $0.point == nextPoint }) {
            let colors: [Item.Kind] = [.Red, .Green, .Blue, .Magenta]
            let color = colors[colorRandomSource.nextIntWithUpperBound(colors.count)]
            items.append(Item(point: nextPoint, kind: color))
        }
    }
}
