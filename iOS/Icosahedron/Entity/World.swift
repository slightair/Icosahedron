import Foundation
import GameplayKit
import RxSwift

class World {
    enum MarkerStatus {
        case None, Red, Green, Blue
    }

    enum Color {
        case Red, Green, Blue
    }

    static let needExpList = [Int.min, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946, 17711, 28657, 46368, 75025, 121393, 196418, 317811, 514229, 832040, 1346269, 2178309, 3524578, 5702887, 9227465, 14930352, 24157816, 39088168, 63245984, 102334152, 165580128, 267914304, 433494464, 701408768, 1134903168, 1836311936, 2971215104, 4807526912, 7778741760, 12586268672, 20365010944, Int.max]

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
            guard redLevel <= World.needExpList.count - 2 else {
                return
            }

            if redCount >= World.needExpList[redLevel] {
                redLevel += 1
            }

            redCountChanged.onNext(redCount)
        }
    }
    let redCountChanged = PublishSubject<Int>()

    var redLevel = 1 {
        didSet {
            redLevelChanged.onNext(redLevel)
        }
    }
    let redLevelChanged = PublishSubject<Int>()

    var greenCount = 0 {
        didSet {
            guard greenLevel <= World.needExpList.count - 2 else {
                return
            }

            if greenCount >= World.needExpList[greenLevel] {
                greenLevel += 1
            }

            greenCountChanged.onNext(greenCount)
        }
    }
    let greenCountChanged = PublishSubject<Int>()

    var greenLevel = 1 {
        didSet {
            greenLevelChanged.onNext(greenLevel)
        }
    }
    let greenLevelChanged = PublishSubject<Int>()

    var blueCount = 0 {
        didSet {
            guard blueLevel <= World.needExpList.count - 2 else {
                return
            }

            if blueCount >= World.needExpList[blueLevel] {
                blueLevel += 1
            }

            blueCountChanged.onNext(blueCount)
        }
    }
    let blueCountChanged = PublishSubject<Int>()

    var blueLevel = 1 {
        didSet {
            blueLevelChanged.onNext(blueLevel)
        }
    }
    let blueLevelChanged = PublishSubject<Int>()

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

    func progressOfColor(color: Color) -> Float {
        if isMaxLevelColor(color) {
            return 1.0
        }

        switch color {
        case .Red:
            let prev = World.needExpList[redLevel - 1]
            let next = World.needExpList[redLevel]
            return Float(redCount - prev) / Float(next - prev)
        case .Green:
            let prev = World.needExpList[greenLevel - 1]
            let next = World.needExpList[greenLevel]
            return Float(greenCount - prev) / Float(next - prev)
        case .Blue:
            let prev = World.needExpList[blueLevel - 1]
            let next = World.needExpList[blueLevel]
            return Float(blueCount - prev) / Float(next - prev)
        }
    }

    func isMaxLevelColor(color: Color) -> Bool {
        switch color {
        case .Red:
            if redLevel == World.needExpList.count - 1 {
                return true
            }
        case .Green:
            if greenLevel == World.needExpList.count - 1 {
                return true
            }
        case .Blue:
            if blueLevel == World.needExpList.count - 1 {
                return true
            }
        }
        return false
    }
}
