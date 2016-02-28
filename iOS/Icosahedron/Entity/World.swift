import Foundation
import GameplayKit
import RxSwift

class World {
    enum MarkerStatus {
        case Marked(color: Color)
    }

    enum Color {
        case Red, Green, Blue
    }

    enum Event {
        case Move(track: Track)
        case ObtainedColorStone(point: Icosahedron.Point, color: Color, score: Int64, combo: Int)
        case ExtendTime(time: Double)
        case GameOver
    }

    static let needExpList = [Int64.min, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946, 17711, 28657, 46368, 75025, 121393, 196418, 317811, 514229, 832040, 1346269, 2178309, 3524578, 5702887, 9227465, 14930352, 24157816, 39088168, 63245984, 102334152, 165580128, 267914304, 433494464, 701408768, 1134903168, 1836311936, 2971215104, 4807526912, 7778741760, 12586268672, 20365010944, Int64.max]

    static let defaultTimeLeft = 15.0
    static let numberOfTracks = 5

    let icosahedron = Icosahedron()
    var markerStatus: MarkerStatus
    var items: [Item] = []

    var prevPoint: Icosahedron.Point? = nil
    var currentPoint = Variable<Icosahedron.Point>(.C)

    let redCount = Variable<Int64>(0)
    let greenCount = Variable<Int64>(0)
    let blueCount = Variable<Int64>(0)

    let redLevel = Variable<Int>(1)
    let greenLevel = Variable<Int>(1)
    let blueLevel = Variable<Int>(1)

    var redProgress: Observable<Float>!
    var greenProgress: Observable<Float>!
    var blueProgress: Observable<Float>!

    var redNextExp: Observable<Int64>!
    var greenNextExp: Observable<Int64>!
    var blueNextExp: Observable<Int64>!

    let turn = Variable<Int>(0)
    let time = Variable<Double>(World.defaultTimeLeft)
    let score = Variable<Int64>(0)

    typealias ChainedItem = (kind: Item.Kind, count: Int)
    var chainedItem: Variable<ChainedItem>

    var tracks: [Track] = [] {
        didSet {
            if tracks.count > World.numberOfTracks {
                tracks.removeFirst()
            }
            updateCompactTracks()
        }
    }

    var compactTracks: [Track] = []

    let pointRandomSource = GKMersenneTwisterRandomSource(seed: 6239)
    let colorRandomSource = GKMersenneTwisterRandomSource(seed: 3962)

    let eventLog = PublishSubject<Event>()

    let disposeBag = DisposeBag()

    var markerColor: World.Color {
        switch markerStatus {
        case .Marked(let color):
            return color
        }
    }

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

        let firstColor: Color = .Blue
        markerStatus = .Marked(color: firstColor)
        chainedItem = Variable<ChainedItem>(ChainedItem(.Stone(color: firstColor), 1))

        setUpObservables()
        setUpSubscriptions()
    }

    func setUpObservables() {
        func convertToProgress(level: Variable<Int>) -> (Int64 -> Float) {
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

        let convertToNextExp: Int -> Int64 = { level in
            World.needExpList[level]
        }

        redNextExp = redLevel.asObservable().map(convertToNextExp)
        greenNextExp = greenLevel.asObservable().map(convertToNextExp)
        blueNextExp = blueLevel.asObservable().map(convertToNextExp)
    }

    func setUpSubscriptions() {
        currentPoint.asObservable().subscribeNext { point in
            let markerColor = self.markerColor

            let itemPoints = self.items.map { $0.point }
            if let itemIndex = itemPoints.indexOf(point) {
                let catchedItem = self.items[itemIndex]
                self.items.removeAtIndex(itemIndex)

                switch catchedItem.kind {
                case .Stone(let color):
                    self.markerStatus = .Marked(color: color)

                    if self.chainedItem.value.kind == catchedItem.kind {
                        self.chainedItem.value = ChainedItem(catchedItem.kind, self.chainedItem.value.count + 1)
                    } else {
                        self.chainedItem.value = ChainedItem(catchedItem.kind, 1)
                    }

                    let colorPoint = Int64(2 ** (self.chainedItem.value.count - 1))
                    let obtainedScore: Int64

                    switch color {
                    case .Red:
                        obtainedScore = Int64(self.redLevel.value) * colorPoint
                        self.redCount.value += colorPoint
                    case .Green:
                        obtainedScore = Int64(self.greenLevel.value) * colorPoint
                        self.greenCount.value += colorPoint
                    case .Blue:
                        obtainedScore = Int64(self.blueLevel.value) * colorPoint
                        self.blueCount.value += colorPoint
                    }

                    self.score.value += obtainedScore

                    let event: Event = .ObtainedColorStone(point: point, color: color, score: obtainedScore, combo: self.chainedItem.value.count)
                    self.eventLog.onNext(event)
                }
            }
            self.putNewItemWithIgnore(point)
            self.turn.value += 1

            if let prev = self.prevPoint {
                let track = Track(start: prev, end: point, color: markerColor, turn: self.turn.value)
                self.tracks.append(track)
                self.eventLog.onNext(.Move(track: track))
            }
            self.prevPoint = point
        }.addDisposableTo(disposeBag)

        func levelUp(level: Variable<Int>) -> (Int64 -> Void) {
            return { count in
                guard level.value <= World.needExpList.count - 2 else {
                    return
                }

                while count >= World.needExpList[level.value] {
                    level.value += 1
                }
            }
        }

        redCount.asObservable().subscribeNext(levelUp(redLevel)).addDisposableTo(disposeBag)
        greenCount.asObservable().subscribeNext(levelUp(greenLevel)).addDisposableTo(disposeBag)
        blueCount.asObservable().subscribeNext(levelUp(blueLevel)).addDisposableTo(disposeBag)

        let extendTime: (Int -> Void) = { level in
            let time = Double(level) / 3.0
            self.time.value += time
            self.eventLog.onNext(.ExtendTime(time: time))
        }

        redLevel.asObservable().subscribeNext(extendTime).addDisposableTo(disposeBag)
        greenLevel.asObservable().subscribeNext(extendTime).addDisposableTo(disposeBag)
        blueLevel.asObservable().subscribeNext(extendTime).addDisposableTo(disposeBag)

        time.asObservable().filter { $0 == 0 }.subscribeNext { _ in
            self.eventLog.onNext(.GameOver)
        }.addDisposableTo(disposeBag)
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

    func updateCompactTracks() {
        var candidate: [Track] = []

        for track in tracks {
            if candidate.isEmpty {
                candidate.append(track)
                continue
            }

            var overlapped = false
            for (index, stored) in candidate.enumerate() {
                if stored.start == track.start && stored.end == track.end ||
                   stored.start == track.end && stored.end == track.start {
                    candidate.removeAtIndex(index)
                    candidate.append(track)
                    overlapped = true
                    break
                }
            }

            if !overlapped {
                candidate.append(track)
            }
        }

        compactTracks = candidate
    }
}
