import GLKit
import OpenGLES
import RxSwift
import RxCocoa
import Chameleon

protocol RendererDelegate {
    func didChangeIcosahedronPoint(point: Icosahedron.Point)
}

class Renderer: NSObject, GLKViewDelegate {
    static var aspect: Float {
        let width = GLsizei(CGRectGetHeight(UIScreen.mainScreen().nativeBounds)) // long side
        let height = GLsizei(CGRectGetWidth(UIScreen.mainScreen().nativeBounds)) // short side

        return Float(fabs(Double(width) / Double(height)))
    }

    let context: EAGLContext
    let world: World
    var delegate: RendererDelegate?

    var modelVertexArray: GLuint = 0
    var modelVertexBuffer: GLuint = 0
    var modelShaderProgram: ModelShaderProgram!
    var uiShaderProgram: UIShaderProgram!

    var projectionMatrix = GLKMatrix4Identity
    var worldMatrix = GLKMatrix4Identity
    var normalMatrix = GLKMatrix3Identity

    let icosahedronModel = MotherIcosahedronModel()
    let markerModel = MarkerModel()
    var objects: [Renderable] {
        func coord(point: Icosahedron.Point) -> GLKVector3 {
            return icosahedronModel.coordinateOfPoint(point)
        }

        markerModel.status = world.markerStatus
        let requiredModels: [Renderable] = [icosahedronModel, markerModel]
        let items: [Renderable] = world.items.map { item in
            let coord = coord(item.point)
            let model = ItemModel(initialPosition: coord, kind: item.kind)
            let rotateQuaternion = GLKQuaternionMakeWithAngleAndVector3Axis(Float(2 * M_PI) * animationLoopValue, GLKVector3Normalize(coord))
            model.quaternion = GLKQuaternionMultiply(rotateQuaternion, model.quaternion)

            return model
        }

        return requiredModels + items
    }

    let pointLabels: [Renderable] = Icosahedron.Point.values.map { LabelModel(text: $0.rawValue) }
    var labelObjects: [Renderable] {
        for model in pointLabels {
            if let label = model as? LabelModel {
                label.quaternion = billboardQuaternion
            }
        }
        return pointLabels
    }

    let redGauge = GaugeModel(color: UIColor.flatRedColor().glColor)
    let greenGauge = GaugeModel(color: UIColor.flatGreenColor().glColor)
    let blueGauge = GaugeModel(color: UIColor.flatBlueColor().glColor)
    let timeGauge = GaugeModel(color: UIColor.flatWhiteColor().glColor)

    var gaugeModels: [Renderable] {
        return [redGauge, greenGauge, blueGauge, timeGauge]
    }

    var uiObjects: [Renderable] {
        return gaugeModels
    }

    let redLevelLabel = LevelLabelModel()
    let greenLevelLabel = LevelLabelModel()
    let blueLevelLabel = LevelLabelModel()

    var levelLabels: [Renderable] {
        return [redLevelLabel, greenLevelLabel, blueLevelLabel]
    }

    let turnLabelModel = LabelModel(text: "Turn 0")
    let scoreLabelModel = LabelModel(text: "Score 0")
    let timeLabelModel = LabelModel(text: String(format: "Time %.3f", arguments: [World.defaultTimeLeft]))

    var uiLabelObjects: [Renderable] {
        return [turnLabelModel, scoreLabelModel, timeLabelModel] + levelLabels
    }

    let fontData: FontData = FontData.defaultData
    var whiteTextureInfo: GLKTextureInfo!

    var prevVertex: IcosahedronVertex!
    var currentVertex: IcosahedronVertex!
    var prevQuaternion = GLKQuaternionIdentity
    var currentQuaternion = GLKQuaternionIdentity
    var animationProgress: Float = 1.0 {
        didSet {
            if prevVertex != nil && currentVertex != nil {
                let markerPosition = GLKVector3Lerp(prevVertex.coordinate, currentVertex.coordinate, animationProgress)
                markerModel.setPosition(markerPosition, prevPosition: prevVertex.coordinate)

                if animationProgress == 1.0 {
                    delegate?.didChangeIcosahedronPoint(currentVertex.point)
                }
            }
        }
    }
    var animationLoopValue: Float = 0.0
    var billboardQuaternion = GLKQuaternionIdentity
    let disposeBag = DisposeBag()

    deinit {
        tearDownGL()
    }

    init(context: EAGLContext, world: World) {
        self.context = context
        self.world = world

        super.init()

        setUpModels()
        setUpSubscriptions()
        setUpGL()

        update()
    }

    func setUpModels() {
        currentVertex = icosahedronModel.pointDict[.C]
        let dummyVertex = icosahedronModel.pointDict[.F]!
        markerModel.setPosition(currentVertex.coordinate, prevPosition: dummyVertex.coordinate)

        for element in pointLabels {
            let label = element as! LabelModel
            let point = Icosahedron.Point(rawValue: label.text)!
            if let vertex = icosahedronModel.pointDict[point] {
                label.position = GLKVector3MultiplyScalar(vertex.coordinate, 1.1)
                label.size = 0.5
            }
            label.customColor = UIColor.flatWhiteColor().glColor
        }

        let itemGaugeModels = [redGauge, greenGauge, blueGauge]
        for (index, gauge) in itemGaugeModels.enumerate() {
            gauge.position = GLKVector3Add(GLKVector3Make(0, 0.075, 0), GLKVector3Make(0, 0.025 * Float(index + 1), 0))
        }

        for (index, model) in levelLabels.enumerate() {
            if let label = model as? LabelModel {
                label.position = GLKVector3Add(GLKVector3Make(0, 0.075, 0), GLKVector3Make(0, 0.025 * Float(index + 1), 0))
                label.size = 0.25
            }
        }

        let maxWidthRatio: Float = 1.0
        let maxHeightRatio: Float = maxWidthRatio / Renderer.aspect

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

        timeGauge.position = GLKVector3Make(rightEdge, topEdge + timeLabelModel.glyphHeight * 1.2, 0)
        timeGauge.width = 0.15
        timeGauge.direction = .RightToLeft
        timeGauge.horizontalAlign = .Right
        timeGauge.verticalAlign = .Top
    }

    func setUpSubscriptions() {
        world.redProgress.bindTo(redGauge.rx_progress).addDisposableTo(disposeBag)
        world.greenProgress.bindTo(greenGauge.rx_progress).addDisposableTo(disposeBag)
        world.blueProgress.bindTo(blueGauge.rx_progress).addDisposableTo(disposeBag)

//        world.redLevel.asObservable().bindTo(redLevelLabel.rx_level).addDisposableTo(disposeBag)
//        world.greenLevel.asObservable().bindTo(greenLevelLabel.rx_level).addDisposableTo(disposeBag)
//        world.blueLevel.asObservable().bindTo(blueLevelLabel.rx_level).addDisposableTo(disposeBag)

        world.turn.asObservable().map { "Turn \($0)" }.bindTo(turnLabelModel.rx_text).addDisposableTo(disposeBag)
        world.time.asObservable().map { String(format: "Time %.3f", arguments: [$0]) }.bindTo(timeLabelModel.rx_text).addDisposableTo(disposeBag)
        world.score.asObservable().map { "Score \($0)" }.bindTo(scoreLabelModel.rx_text).addDisposableTo(disposeBag)

        let timeGaugeMax: Float = 30.0
        world.time.asObservable().map { 1.0 - (timeGaugeMax - min(timeGaugeMax, Float($0))) / timeGaugeMax }.bindTo(timeGauge.rx_progress).addDisposableTo(disposeBag)

        // for Debug

        let debugLevelText: (Int, Int64, Int64) -> String = { (level, count, nextExp) in
            return "Lv \(level)(\(count)/\(nextExp))"
        }

        Observable.combineLatest(world.redLevel.asObservable(),
            world.redCount.asObservable(),
            world.redNextExp.asObservable(),
            resultSelector: debugLevelText)
            .bindTo(redLevelLabel.rx_text)
            .addDisposableTo(disposeBag)
        Observable.combineLatest(world.greenLevel.asObservable(),
            world.greenCount.asObservable(),
            world.greenNextExp.asObservable(),
            resultSelector: debugLevelText)
            .bindTo(greenLevelLabel.rx_text)
            .addDisposableTo(disposeBag)
        Observable.combineLatest(world.blueLevel.asObservable(),
            world.blueCount.asObservable(),
            world.blueNextExp.asObservable(),
            resultSelector: debugLevelText)
            .bindTo(blueLevelLabel.rx_text)
            .addDisposableTo(disposeBag)
    }

    func setUpGL() {
        EAGLContext.setCurrentContext(context)

        modelShaderProgram = ModelShaderProgram()
        uiShaderProgram = UIShaderProgram()

        let projectionWidth: Float = 1.0
        let projectionHeight = projectionWidth / Renderer.aspect
        projectionMatrix = GLKMatrix4MakeOrtho(-projectionWidth / 2, projectionWidth / 2, -projectionHeight / 2, projectionHeight / 2, 0.1, 100)

        glGenVertexArrays(1, &modelVertexArray)
        glBindVertexArray(modelVertexArray)

        glGenBuffers(1, &modelVertexBuffer)

        glBindVertexArray(0)

        guard let whiteTextureAsset = NSDataAsset(name: "White") else {
            fatalError("white texture file not found")
        }
        whiteTextureInfo = try! GLKTextureLoader.textureWithContentsOfData(whiteTextureAsset.data, options: nil)
        fontData.loadTexture()
    }

    func tearDownGL() {
        glDeleteBuffers(1, &modelVertexBuffer)
        glDeleteVertexArrays(1, &modelVertexArray)
    }

    func rotateModelWithTappedLocation(location: CGPoint) {
        if animationProgress < 1.0 {
            return
        }

        let locationVector = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(worldMatrix, nil), GLKVector3Make(Float(location.x), Float(location.y), 0))

        var nearestDistance = FLT_MAX
        var nearestVertex: IcosahedronVertex?
        for vertex in currentVertex.nextVertices {
            let distance = GLKVector3Distance(locationVector, vertex.coordinate)
            if distance < nearestDistance {
                nearestDistance = distance
                nearestVertex = vertex
            }
        }

        if let selectedVertex = nearestVertex {
            moveToVertex(selectedVertex)
        }
    }

    func moveToVertex(vertex: IcosahedronVertex) {
        prevVertex = currentVertex
        currentVertex = vertex
        animationProgress = 0.0

        let relativeQuaternion = quaternionForRotate(from: currentVertex.coordinate, to: prevVertex.coordinate)

        prevQuaternion = currentQuaternion
        currentQuaternion = GLKQuaternionMultiply(currentQuaternion, relativeQuaternion)
    }

    func renderModels(models: [Renderable]) {
        let modelVertices = models.flatMap { $0.modelVertices }
        let vertices: [Float] = modelVertices.flatMap { $0.v }

        glBindVertexArray(modelVertexArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), modelVertexBuffer)

        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(ModelVertex.size * modelVertices.count), vertices, GLenum(GL_STREAM_DRAW))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(0))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(sizeof(Float) * 3))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(sizeof(Float) * 6))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.TexCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.TexCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(sizeof(Float) * 10))

        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(modelVertices.count))

        glBindVertexArray(0)
    }

    func update(timeSinceLastUpdate: NSTimeInterval = 0) {
        if animationProgress < 1.0 {
            animationProgress = min(1.0, animationProgress + Float(timeSinceLastUpdate) * 4)
        }

        animationLoopValue += Float(timeSinceLastUpdate / 4)
        if animationLoopValue > 1.0 {
            animationLoopValue -= 1.0
        }

        let baseQuaternion = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(150), 1.0, 0.0, 0.0)
        let movingQuaternion = GLKQuaternionSlerp(prevQuaternion, currentQuaternion, animationProgress)
        let worldQuaternion = GLKQuaternionMultiply(baseQuaternion, movingQuaternion)
        billboardQuaternion = GLKQuaternionInvert(movingQuaternion)

        let baseMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -1.0)
        worldMatrix = GLKMatrix4Multiply(baseMatrix, GLKMatrix4MakeWithQuaternion(worldQuaternion))
        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(worldMatrix), nil)
    }

    // MARK: - GLKView delegate methods

    func glkView(view: GLKView, drawInRect rect: CGRect) {
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))

        glEnable(GLenum(GL_DEPTH_TEST))

        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(modelShaderProgram.programID)

        modelShaderProgram.projectionMatrix = projectionMatrix
        modelShaderProgram.worldMatrix = worldMatrix
        modelShaderProgram.normalMatrix = normalMatrix

        glActiveTexture(GLenum(GL_TEXTURE0))

        glBindTexture(GLenum(GL_TEXTURE_2D), whiteTextureInfo.name)
        renderModels(objects)

        glBindTexture(GLenum(GL_TEXTURE_2D), fontData.textureInfo.name)
        renderModels(labelObjects)

        glDisable(GLenum(GL_DEPTH_TEST))

        glUseProgram(uiShaderProgram.programID)

        uiShaderProgram.projectionMatrix = projectionMatrix

        glBindTexture(GLenum(GL_TEXTURE_2D), whiteTextureInfo.name)
        renderModels(uiObjects)

        glBindTexture(GLenum(GL_TEXTURE_2D), fontData.textureInfo.name)
        renderModels(uiLabelObjects)
    }
}
