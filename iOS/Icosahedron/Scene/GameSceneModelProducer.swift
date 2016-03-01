import GLKit
import RxSwift
import RxCocoa
import Chameleon

class GameSceneModelProducer {
    let world: World

    let sphereModel = SphereModel()
    let icosahedronModel = MotherIcosahedronModel()
    let markerModel: MarkerModel

    var floatingScoreLabels: [Icosahedron.Point: FloatingLabelModel] = [:]

    let timeGaugeModel = GaugeModel(color: UIColor.flatWhiteColor().colorWithAlphaComponent(0.8).glColor, bgColor:UIColor.flatWhiteColor().colorWithAlphaComponent(0.3).glColor)

    let phaseLabelModel = LabelModel(text: "Phase 0")
    let scoreLabelModel = LabelModel(text: "Score 0")
    let timeLabelModel = LabelModel(text: String(format: "Time %.3f", arguments: [World.phaseInterval]))
    let infoLabelModelGroup = SequenceLabelModelGroup()

    var icosahedronPointParticleEmitters: [Icosahedron.Point: ParticleEmitter] = [:]

    var animationLoopValue: Float = 0.0
    var noiseFactor: Float = 0.0
    var effectColor: GLKVector4 = GLKVector4Make(1, 1, 1, 1)
    var effectColorFactor: Float = 0.0

    let disposeBag = DisposeBag()

    init(world: World) {
        self.world = world
        self.markerModel = MarkerModel(status: world.markerStatus)

        setUpModels()
        setUpPoints()
        setUpSubscriptions()
    }

    func setUpModels() {
        for point in Icosahedron.Point.values {
            let scoreLabel = FloatingLabelModel(text: "")
            scoreLabel.baseTextColor = UIColor.flatWhiteColor().glColor

            if let vertex = icosahedronModel.pointDict[point] {
                scoreLabel.position = GLKVector3MultiplyScalar(vertex.coordinate, 1.1)
                scoreLabel.baseSize = 0.3
                scoreLabel.duration = 1.0
            }

            floatingScoreLabels[point] = scoreLabel
        }

        let maxWidthRatio: Float = 1.0
        let maxHeightRatio: Float = maxWidthRatio / Screen.aspect

        let leftEdge = -maxWidthRatio / 2 * 0.98
        let rightEdge = maxWidthRatio / 2 * 0.98
        let topEdge = -maxHeightRatio / 2 * 0.98
        let bottomEdge = maxHeightRatio / 2 * 0.98

        let infoLabelSize: Float = 0.25
        phaseLabelModel.position = GLKVector3Make(0, bottomEdge, 0)
        phaseLabelModel.size = infoLabelSize
        phaseLabelModel.horizontalAlign = .Center
        phaseLabelModel.verticalAlign = .Bottom

        scoreLabelModel.position = GLKVector3Make(leftEdge, topEdge, 0)
        scoreLabelModel.size = infoLabelSize
        scoreLabelModel.horizontalAlign = .Left
        scoreLabelModel.verticalAlign = .Top

        timeLabelModel.position = GLKVector3Make(rightEdge, topEdge, 0)
        timeLabelModel.size = infoLabelSize
        timeLabelModel.horizontalAlign = .Right
        timeLabelModel.verticalAlign = .Top

        timeGaugeModel.position = GLKVector3Make(0, maxHeightRatio / 2, 0)
        timeGaugeModel.width = 1.0
        timeGaugeModel.direction = .RightToLeft
        timeGaugeModel.horizontalAlign = .Center
        timeGaugeModel.verticalAlign = .Bottom

        infoLabelModelGroup.position = GLKVector3Make(0, -maxHeightRatio / 4 - 0.03, 0)
        infoLabelModelGroup.size = 0.3
        infoLabelModelGroup.verticalAlign = .Top
        infoLabelModelGroup.direction = .Up
        infoLabelModelGroup.duration = 2.0
        infoLabelModelGroup.showBackground = true
    }

    func setUpPoints() {
        for point in Icosahedron.Point.values {
            let particleEmitter = ParticleEmitter()
            particleEmitter.emissionInterval = 0.005
            particleEmitter.duration = 0.1
            particleEmitter.positionFunction = { self.icosahedronModel.coordinateOfPoint(point) }
            particleEmitter.speedFunction = { 0.1 }

            icosahedronPointParticleEmitters[point] = particleEmitter
        }
    }

    func setUpSubscriptions() {
        world.phase.asObservable().map { "Phase \($0)" }.bindTo(phaseLabelModel.rx_text).addDisposableTo(disposeBag)
        world.time.asObservable().map { String(format: "Time %.3f", arguments: [$0]) }.bindTo(timeLabelModel.rx_text).addDisposableTo(disposeBag)
        world.score.asObservable().map { "Score \($0)" }.bindTo(scoreLabelModel.rx_text).addDisposableTo(disposeBag)

        let timeGaugeMax = Float(World.phaseInterval)
        world.time.asObservable().map { 1.0 - (timeGaugeMax - min(timeGaugeMax, Float($0))) / timeGaugeMax }.bindTo(timeGaugeModel.rx_progress).addDisposableTo(disposeBag)

        world.eventLog.subscribeNext { event in
            switch event {
            case .ObtainedColorStone(let point, let color):
                if let particleEmitter = self.icosahedronPointParticleEmitters[point] {
                    particleEmitter.colorFunction = { color.modelColor() }
                    particleEmitter.emit()
                }

                self.effectColor = color.modelColor()
                self.effectColorFactor = 0.5

            case .PhaseChanged(let phase):
                self.infoLabelModelGroup.appendNewLabel("Phase \(phase)", color: UIColor.flatWhiteColor().glColor)

            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }

    func backgroundModelObjects() -> [Renderable] {
        return [sphereModel]
    }

    func modelObjects() -> [Renderable] {
        func coord(point: Icosahedron.Point) -> GLKVector3 {
            return icosahedronModel.coordinateOfPoint(point)
        }

        markerModel.status = world.markerStatus
        let requiredModels: [Renderable] = [icosahedronModel, markerModel]
        let angle = Float(2 * M_PI) * animationLoopValue / 4
        let itemModels: [Renderable] = world.items.map { item in
            let coord = coord(item.point)
            let model = ItemModel(initialPosition: coord, kind: item.kind)
            let rotateQuaternion = GLKQuaternionMakeWithAngleAndVector3Axis(angle, GLKVector3Normalize(coord))
            model.quaternion = GLKQuaternionMultiply(rotateQuaternion, model.quaternion)

            return model
        }

        let trackAlphaStep = 1.0 / Float(World.numberOfTracks + 1)
        let trackModels: [Renderable] = world.compactTracks.map { track in
            let startPosition = icosahedronModel.coordinateOfPoint(track.start)
            let endPosition = icosahedronModel.coordinateOfPoint(track.end)

            let alpha = 1.0 - Float(world.turn.value - track.turn) * trackAlphaStep
            let model = TrackModel(leftPosition: startPosition, rightPosition: endPosition, color: track.color, alpha: CGFloat(alpha))

            return model
        }

        return requiredModels + itemModels + trackModels
    }

    func labelObjects() -> [LabelModel] {
        return floatingScoreLabels.map { $1 }.filter { $0.isActive }
    }

    func uiObjects() -> [Renderable] {
        return [
            timeGaugeModel,
        ]
    }

    func uiLabelObjects() -> [Renderable] {
        var labels: [Renderable] = [
            phaseLabelModel,
            scoreLabelModel,
            timeLabelModel,
        ]

        labels.appendContentsOf(infoLabelModelGroup.activeLabels.map { $0 as Renderable })

        return labels
    }

    func particlePoints() -> [ParticleVertex] {
        return icosahedronPointParticleEmitters.values.flatMap { $0.activeParticles.map { $0.vertex } }
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        animationLoopValue += Float(timeSinceLastUpdate)
        if animationLoopValue > 1.0 {
            animationLoopValue -= 1.0
        }

        for (_, label) in floatingScoreLabels {
            label.update(timeSinceLastUpdate)
        }

        infoLabelModelGroup.update(timeSinceLastUpdate)

        for particleEmitter in icosahedronPointParticleEmitters.values {
            particleEmitter.update(timeSinceLastUpdate)
        }

        let markerScale = Float(1.0 + 0.2 * cos(2 * M_PI * Double(animationLoopValue)))
        markerModel.scale = GLKVector3Make(markerScale, 1.0, markerScale)

        if effectColorFactor > 0.0 {
            effectColorFactor = max(0.0, effectColorFactor - Float(timeSinceLastUpdate))
        }
    }
}
