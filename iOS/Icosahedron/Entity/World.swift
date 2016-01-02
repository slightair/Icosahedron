import Foundation
import GameplayKit
import RxSwift

class World {
    enum MarkerStatus {
        case Neutral, Marked(color: Color)
    }

    enum Color {
        case Red, Green, Blue
    }

    static let needExpList = [Int.min, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946, 17711, 28657, 46368, 75025, 121393, 196418, 317811, 514229, 832040, 1346269, 2178309, 3524578, 5702887, 9227465, 14930352, 24157816, 39088168, 63245984, 102334152, 165580128, 267914304, 433494464, 701408768, 1134903168, 1836311936, 2971215104, 4807526912, 7778741760, 12586268672, 20365010944, Int.max]

    static let defaultTimeLeft = 15.0

    let icosahedron = Icosahedron()
    var markerStatus: MarkerStatus = .Neutral
    var items: [Item] = []

    var currentPoint = Variable<Icosahedron.Point>(.C)

    let redCount = Variable<Int>(0)
    let greenCount = Variable<Int>(0)
    let blueCount = Variable<Int>(0)

    let redLevel = Variable<Int>(1)
    let greenLevel = Variable<Int>(1)
    let blueLevel = Variable<Int>(1)

    var redProgress: Observable<Float>!
    var greenProgress: Observable<Float>!
    var blueProgress: Observable<Float>!

    let turn = Variable<Int>(0)
    let time = Variable<Double>(World.defaultTimeLeft)

    let pointRandomSource = GKMersenneTwisterRandomSource(seed: 6239)
    let colorRandomSource = GKMersenneTwisterRandomSource(seed: 3962)

    let disposeBag = DisposeBag()

    init() {
        items = [
            Item(point: .A, kind: .Stone(color: .Red)),
            Item(point: .B, kind: .Stone(color: .Green)),
            Item(point: .D, kind: .Stone(color: .Red)),
            Item(point: .E, kind: .Stone(color: .Green)),
            Item(point: .F, kind: .Stone(color: .Blue)),
            Item(point: .G, kind: .Stone(color: .Red)),
            Item(point: .H, kind: .Stone(color: .Green)),
            Item(point: .I, kind: .Stone(color: .Blue)),
            Item(point: .J, kind: .Stone(color: .Red)),
            Item(point: .K, kind: .Stone(color: .Green)),
            Item(point: .L, kind: .Stone(color: .Blue)),
        ]

        setUpObservables()
        setUpSubscriptions()
    }

    func setUpObservables() {
        func convertToProgress(level: Variable<Int>) -> (Int -> Float) {
            return { count in
                if count == 0 {
                    return 0.0
                }
                if level.value == World.needExpList.count - 1 {
                    return 1.0
                }
                let prev = World.needExpList[level.value - 1]
                let next = World.needExpList[level.value]
                return Float(count - prev) / Float(next - prev)
            }
        }

        redProgress = redCount.asObservable().map(convertToProgress(redLevel))
        greenProgress = greenCount.asObservable().map(convertToProgress(greenLevel))
        blueProgress = blueCount.asObservable().map(convertToProgress(blueLevel))
    }

    func setUpSubscriptions() {
        currentPoint.subscribeNext { point in
            let itemPoints = self.items.map { $0.point }

            if let itemIndex = itemPoints.indexOf(point) {
                let catchedItem = self.items[itemIndex]
                self.items.removeAtIndex(itemIndex)

                switch catchedItem.kind {
                case .Stone(let color):
                    self.markerStatus = .Marked(color: color)
                    switch color {
                    case .Red:
                        self.redCount.value += 1
                    case .Green:
                        self.greenCount.value += 1
                    case .Blue:
                        self.blueCount.value += 1
                    }
                }
            }
            self.putNewItemWithIgnore(point)
            self.turn.value += 1
        }.addDisposableTo(disposeBag)

        func levelUp(level: Variable<Int>) -> (Int -> Void) {
            return { count in
                guard level.value <= World.needExpList.count - 2 else {
                    return
                }
                if count >= World.needExpList[level.value] {
                    level.value += 1
                }
            }
        }

        redCount.subscribeNext(levelUp(redLevel)).addDisposableTo(disposeBag)
        greenCount.subscribeNext(levelUp(greenLevel)).addDisposableTo(disposeBag)
        blueCount.subscribeNext(levelUp(blueLevel)).addDisposableTo(disposeBag)
    }

    func putNewItemWithIgnore(ignore: Icosahedron.Point) {
        var candidate = Icosahedron.Point.values
        let ignoreIndex = candidate.indexOf(ignore)
        candidate.removeAtIndex(ignoreIndex!)

        let nextPoint = candidate[pointRandomSource.nextIntWithUpperBound(candidate.count)]
        if !items.contains({ $0.point == nextPoint }) {
            let color = Item.Kind.values[colorRandomSource.nextIntWithUpperBound(Item.Kind.values.count)]
            items.append(Item(point: nextPoint, kind: color))
        }
    }

    func update(timeSinceLastUpdate: NSTimeInterval = 0) {
        if time.value > 0 {
            let nextTime = max(0, time.value - timeSinceLastUpdate)
            time.value = nextTime
        }
    }

    func itemOfPoint(point: Icosahedron.Point) -> Item? {
        if let index = items.indexOf({ $0.point == point }) {
            return items[index]
        }
        return nil
    }
}
