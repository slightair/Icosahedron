import GLKit
import RxSwift
import RxCocoa
import Chameleon

class GameSceneModelProducer {
    let world: World

    let icosahedronModel = MotherIcosahedronModel()
    let markerModel = MarkerModel()

    let pointLabels = Icosahedron.Point.values.map { LabelModel(text: $0.rawValue) }

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

    var animationLoopValue: Float = 0.0

    let disposeBag = DisposeBag()

    init(world: World) {
        self.world = world

        setUpModels()
        setUpSubscriptions()
    }

    func setUpModels() {
        for label in pointLabels {
            let point = Icosahedron.Point(rawValue: label.text)!
            if let vertex = icosahedronModel.pointDict[point] {
                label.position = GLKVector3MultiplyScalar(vertex.coordinate, 1.1)
                label.size = 0.5
            }
            label.customColor = UIColor.flatWhiteColor().glColor
        }

        let itemGaugeModels = [redGaugeModel, greenGaugeModel, blueGaugeModel]
        for (index, gauge) in itemGaugeModels.enumerate() {
            gauge.position = GLKVector3Add(GLKVector3Make(0, 0.075, 0), GLKVector3Make(0, 0.025 * Float(index + 1), 0))
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
    }

    func setUpSubscriptions() {
        world.redProgress.bindTo(redGaugeModel.rx_progress).addDisposableTo(disposeBag)
        world.greenProgress.bindTo(greenGaugeModel.rx_progress).addDisposableTo(disposeBag)
        world.blueProgress.bindTo(blueGaugeModel.rx_progress).addDisposableTo(disposeBag)

        //        world.redLevel.asObservable().bindTo(redLevelLabel.rx_level).addDisposableTo(disposeBag)
        //        world.greenLevel.asObservable().bindTo(greenLevelLabel.rx_level).addDisposableTo(disposeBag)
        //        world.blueLevel.asObservable().bindTo(blueLevelLabel.rx_level).addDisposableTo(disposeBag)

        world.turn.asObservable().map { "Turn \($0)" }.bindTo(turnLabelModel.rx_text).addDisposableTo(disposeBag)
        world.time.asObservable().map { String(format: "Time %.3f", arguments: [$0]) }.bindTo(timeLabelModel.rx_text).addDisposableTo(disposeBag)
        world.score.asObservable().map { "Score \($0)" }.bindTo(scoreLabelModel.rx_text).addDisposableTo(disposeBag)

        let timeGaugeMax: Float = 30.0
        world.time.asObservable().map { 1.0 - (timeGaugeMax - min(timeGaugeMax, Float($0))) / timeGaugeMax }.bindTo(timeGaugeModel.rx_progress).addDisposableTo(disposeBag)

        // for Debug

        let debugLevelText: (Int, Int64, Int64) -> String = { (level, count, nextExp) in
            return "Lv \(level)(\(count)/\(nextExp))"
        }

        Observable.combineLatest(world.redLevel.asObservable(),
            world.redCount.asObservable(),
            world.redNextExp.asObservable(),
            resultSelector: debugLevelText)
            .bindTo(redLevelLabelModel.rx_text)
            .addDisposableTo(disposeBag)
        Observable.combineLatest(world.greenLevel.asObservable(),
            world.greenCount.asObservable(),
            world.greenNextExp.asObservable(),
            resultSelector: debugLevelText)
            .bindTo(greenLevelLabelModel.rx_text)
            .addDisposableTo(disposeBag)
        Observable.combineLatest(world.blueLevel.asObservable(),
            world.blueCount.asObservable(),
            world.blueNextExp.asObservable(),
            resultSelector: debugLevelText)
            .bindTo(blueLevelLabelModel.rx_text)
            .addDisposableTo(disposeBag)
    }

    func modelObjects() -> [Renderable] {
        func coord(point: Icosahedron.Point) -> GLKVector3 {
            return icosahedronModel.coordinateOfPoint(point)
        }

        markerModel.status = world.markerStatus
        let requiredModels: [Renderable] = [icosahedronModel, markerModel]
        let itemModels: [Renderable] = world.items.map { item in
            let coord = coord(item.point)
            let model = ItemModel(initialPosition: coord, kind: item.kind)
            let rotateQuaternion = GLKQuaternionMakeWithAngleAndVector3Axis(Float(2 * M_PI) * animationLoopValue, GLKVector3Normalize(coord))
            model.quaternion = GLKQuaternionMultiply(rotateQuaternion, model.quaternion)

            return model
        }

        return requiredModels + itemModels
    }

    func labelObjects() -> [LabelModel] {
        return pointLabels
    }

    func uiObjects() -> [Renderable] {
        return [
            redGaugeModel,
            greenGaugeModel,
            blueGaugeModel,
        ]
    }

    func uiLabelObjects() -> [Renderable] {
        return [
            turnLabelModel,
            scoreLabelModel,
            timeLabelModel,
            redLevelLabelModel,
            greenLevelLabelModel,
            blueLevelLabelModel,
        ]
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        animationLoopValue += Float(timeSinceLastUpdate / 4)
        if animationLoopValue > 1.0 {
            animationLoopValue -= 1.0
        }
    }
}
