import Foundation
import GameplayKit
import RxSwift

class World {
    enum MarkerStatus {
        case Marked(color: Color)
    }

    enum Color {
        case Red, Green, Blue

        static let values: [Color] = [.Red, .Green, .Blue]

        static func random() -> Color {
            let needle = Int(arc4random_uniform(UInt32(values.count)))
            return values[needle]
        }
    }

    enum Event {
        case Move(track: Track)
        case ObtainedColorStone(point: Icosahedron.Point, color: Color)
        case PhaseChanged(phase: Phase)
        case GameOver
    }

    static let phaseInterval = 10.0
    static let numberOfTracks = 9

    let icosahedron = Icosahedron()
    var markerStatus: MarkerStatus
    var items: [Item] = []

    var prevPoint: Icosahedron.Point? = nil
    var currentPoint = Variable<Icosahedron.Point>(.C)

    let redCount = Variable<Int>(0)
    let greenCount = Variable<Int>(0)
    let blueCount = Variable<Int>(0)

    let turn = Variable<Int>(0)
    let phase = Variable<Phase>(Phase(number: 1))
    let time = Variable<Double>(World.phaseInterval)
    let score = Variable<Int64>(0)

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

        setUpSubscriptions()
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

                    switch color {
                    case .Red:
                        self.redCount.value += 1
                    case .Green:
                        self.greenCount.value += 1
                    case .Blue:
                        self.blueCount.value += 1
                    }

                    let event: Event = .ObtainedColorStone(point: point, color: color)
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

        phase.asObservable().subscribeNext { value in
            self.eventLog.onNext(.PhaseChanged(phase: value))
            self.time.value = World.phaseInterval
        }.addDisposableTo(disposeBag)

        time.asObservable().filter { $0 == 0 }.subscribeNext { _ in
            let nextPhaseNumber = self.phase.value.number + 1
            self.phase.value = Phase(number: nextPhaseNumber)
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
