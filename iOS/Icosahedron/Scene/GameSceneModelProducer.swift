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

    let redGaugeModel = GaugeModel(color: UIColor.flatRedColor().glColor)
    let greenGaugeModel = GaugeModel(color: UIColor.flatGreenColor().glColor)
    let blueGaugeModel = GaugeModel(color: UIColor.flatBlueColor().glColor)
    let timeGaugeModel = GaugeModel(color: UIColor.flatWhiteColor().glColor)

    let redLevelLabelModel = LevelLabelModel()
    let greenLevelLabelModel = LevelLabelModel()
    let blueLevelLabelModel = LevelLabelModel()

    let turnLabelModel = LabelModel(text: "Turn 0")
    let scoreLabelModel = LabelModel(text: "Score 0")
    let timeLabelModel = LabelModel(text: String(format: "Time %.3f", arguments: [World.defaultTimeLeft]))
    let extendTimeLabelModelGroup = SequenceLabelModelGroup()
    let comboLabelModelGroup = SequenceLabelModelGroup()

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

        let itemGaugeModels = [redGaugeModel, greenGaugeModel, blueGaugeModel]
        for (index, gauge) in itemGaugeModels.enumerate() {
            gauge.position = GLKVector3Add(GLKVector3Make(0, 0.075, 0), GLKVector3Make(0, 0.025 * Float(index + 1), 0))
            gauge.width = 0.15
            gauge.height = 0.01
        }

        let levelLabelModels = [redLevelLabelModel, greenLevelLabelModel, blueLevelLabelModel]
        for (index, label) in levelLabelModels.enumerate() {
            label.position = GLKVector3Add(GLKVector3Make(0, 0.075, 0), GLKVector3Make(0, 0.025 * Float(index + 1), 0))
            label.size = 0.25
        }

        let maxWidthRatio: Float = 1.0
        let maxHeightRatio: Float = maxWidthRatio / Screen.aspect

        let leftEdge = -maxWidthRatio / 2 * 0.98
        let rightEdge = maxWidthRatio / 2 * 0.98
        let topEdge = -maxHeightRatio / 2 * 0.98
        let bottomEdge = maxHeightRatio / 2 * 0.98

        let infoLabelSize: Float = 0.25
        turnLabelModel.position = GLKVector3Make(leftEdge, bottomEdge, 0)
        turnLabelModel.size = infoLabelSize
        turnLabelModel.horizontalAlign = .Left
        turnLabelModel.verticalAlign = .Bottom

        scoreLabelModel.position = GLKVector3Make(leftEdge, topEdge, 0)
        scoreLabelModel.size = infoLabelSize
        scoreLabelModel.horizontalAlign = .Left
        scoreLabelModel.verticalAlign = .Top

        timeLabelModel.position = GLKVector3Make(rightEdge, topEdge, 0)
        timeLabelModel.size = infoLabelSize
        timeLabelModel.horizontalAlign = .Right
        timeLabelModel.verticalAlign = .Top

        timeGaugeModel.position = GLKVector3Make(rightEdge, topEdge + timeLabelModel.glyphHeight * 1.2, 0)
        timeGaugeModel.width = 0.15
        timeGaugeModel.direction = .RightToLeft
        timeGaugeModel.horizontalAlign = .Right
        timeGaugeModel.verticalAlign = .Top

        extendTimeLabelModelGroup.position = GLKVector3Make(rightEdge, timeGaugeModel.position.y + timeGaugeModel.height * 1.5, 0)
        extendTimeLabelModelGroup.size = infoLabelSize
        extendTimeLabelModelGroup.horizontalAlign = .Right
        extendTimeLabelModelGroup.verticalAlign = .Top
        extendTimeLabelModelGroup.duration = 1.5

        comboLabelModelGroup.position = GLKVector3Make(0, -maxHeightRatio / 4 - 0.03, 0)
        comboLabelModelGroup.size = 0.3
        comboLabelModelGroup.verticalAlign = .Top
        comboLabelModelGroup.direction = .Up
        comboLabelModelGroup.duration = 2.0
        comboLabelModelGroup.showBackground = true
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
        world.redProgress.bindTo(redGaugeModel.rx_progress).addDisposableTo(disposeBag)
        world.greenProgress.bindTo(greenGaugeModel.rx_progress).addDisposableTo(disposeBag)
        world.blueProgress.bindTo(blueGaugeModel.rx_progress).addDisposableTo(disposeBag)

        world.redLevel.asObservable().bindTo(redLevelLabelModel.rx_level).addDisposableTo(disposeBag)
        world.greenLevel.asObservable().bindTo(greenLevelLabelModel.rx_level).addDisposableTo(disposeBag)
        world.blueLevel.asObservable().bindTo(blueLevelLabelModel.rx_level).addDisposableTo(disposeBag)

        world.turn.asObservable().map { "Turn \($0)" }.bindTo(turnLabelModel.rx_text).addDisposableTo(disposeBag)
        world.time.asObservable().map { String(format: "Time %.3f", arguments: [$0]) }.bindTo(timeLabelModel.rx_text).addDisposableTo(disposeBag)
        world.score.asObservable().map { "Score \($0)" }.bindTo(scoreLabelModel.rx_text).addDisposableTo(disposeBag)

        let timeGaugeMax: Float = 30.0
        world.time.asObservable().map { 1.0 - (timeGaugeMax - min(timeGaugeMax, Float($0))) / timeGaugeMax }.bindTo(timeGaugeModel.rx_progress).addDisposableTo(disposeBag)

        world.eventLog.subscribeNext { event in
            switch event {
            case .ObtainedColorStone(let point, let color, let score, let combo):
                if let scoreLabel = self.floatingScoreLabels[point] {
                    scoreLabel.text = String(score)
                    scoreLabel.animationProgress = 0.0
                }

                if let particleEmitter = self.icosahedronPointParticleEmitters[point] {
                    particleEmitter.colorFunction = { color.modelColor() }
                    particleEmitter.emit()
                }

                if combo > 1 {
                    let comboText = String(format: "Combo \(combo)")
                    self.comboLabelModelGroup.appendNewLabel(comboText, color: color.modelColor())
                } else {
                    self.noiseFactor = 0.3
                }

                self.effectColor = color.modelColor()
                self.effectColorFactor = 0.5

            case .ExtendTime(let time):
                let timeText = String(format: "+%.1fsec", arguments: [time])
                self.extendTimeLabelModelGroup.appendNewLabel(timeText, color: UIColor.flatWhiteColor().glColor)
            default:
                break
            }
        }.addDisposableTo(disposeBag)

        // for Debug

//        let debugLevelText: (Int, Int64, Int64) -> String = { (level, count, nextExp) in
//            return "Lv \(level)(\(count)/\(nextExp))"
//        }
//
//        Observable.combineLatest(world.redLevel.asObservable(),
//            world.redCount.asObservable(),
//            world.redNextExp.asObservable(),
//            resultSelector: debugLevelText)
//            .bindTo(redLevelLabelModel.rx_text)
//            .addDisposableTo(disposeBag)
//        Observable.combineLatest(world.greenLevel.asObservable(),
//            world.greenCount.asObservable(),
//            world.greenNextExp.asObservable(),
//            resultSelector: debugLevelText)
//            .bindTo(greenLevelLabelModel.rx_text)
//            .addDisposableTo(disposeBag)
//        Observable.combineLatest(world.blueLevel.asObservable(),
//            world.blueCount.asObservable(),
//            world.blueNextExp.asObservable(),
//            resultSelector: debugLevelText)
//            .bindTo(blueLevelLabelModel.rx_text)
//            .addDisposableTo(disposeBag)
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

        let trackModels: [Renderable] = world.compactTracks.map { track in
            let startPosition = icosahedronModel.coordinateOfPoint(track.start)
            let endPosition = icosahedronModel.coordinateOfPoint(track.end)
            let model = TrackModel(leftPosition: startPosition, rightPosition: endPosition, color: track.color)

            return model
        }

        return requiredModels + itemModels + trackModels
    }

    func labelObjects() -> [LabelModel] {
        return floatingScoreLabels.map { $1 }.filter { $0.isActive }
    }

    func uiObjects() -> [Renderable] {
        return [
            redGaugeModel,
            greenGaugeModel,
            blueGaugeModel,
            timeGaugeModel,
        ]
    }

    func uiLabelObjects() -> [Renderable] {
        var labels: [Renderable] = [
            turnLabelModel,
            scoreLabelModel,
            timeLabelModel,
            redLevelLabelModel,
            greenLevelLabelModel,
            blueLevelLabelModel,
        ]

        labels.appendContentsOf(extendTimeLabelModelGroup.activeLabels.map { $0 as Renderable })
        labels.appendContentsOf(comboLabelModelGroup.activeLabels.map { $0 as Renderable })

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

        extendTimeLabelModelGroup.update(timeSinceLastUpdate)
        comboLabelModelGroup.update(timeSinceLastUpdate)

        for particleEmitter in icosahedronPointParticleEmitters.values {
            particleEmitter.update(timeSinceLastUpdate)
        }

        let markerScale = Float(1.0 + 0.2 * cos(2 * M_PI * Double(animationLoopValue)))
        markerModel.scale = GLKVector3Make(markerScale, 1.0, markerScale)

        if noiseFactor > 0.0 {
            noiseFactor = max(0.0, noiseFactor - Float(timeSinceLastUpdate))
        }

        if effectColorFactor > 0.0 {
            effectColorFactor = max(0.0, effectColorFactor - Float(timeSinceLastUpdate))
        }
    }
}
