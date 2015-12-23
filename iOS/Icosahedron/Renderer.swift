import GLKit
import OpenGLES

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
        let items: [Renderable] = world.items.map { ItemModel(initialPosition: coord($0.point), kind: $0.kind) }
        let roads: [Renderable] = world.roads.map { RoadModel(leftPosition: coord($0.left), rightPosition: coord($0.right), kind: $0.kind)}

        return requiredModels + items + roads
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

    let gaugeModels: [Renderable] = [
        GaugeModel(color: UIColor.flatRedColor().glColor),
        GaugeModel(color: UIColor.flatGreenColor().glColor),
        GaugeModel(color: UIColor.flatBlueColor().glColor),
    ]
    var uiObjects: [Renderable] {
        return gaugeModels
    }

    let countLabelModel = LabelModel(text: "Count:0")
    var uiLabelObjects: [Renderable] {
        return [countLabelModel]
    }

    let font: Font = Font.Default
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

                    countLabelModel.text = "Count:\(world.moveCount)"
                }
            }
        }
    }
    var billboardQuaternion = GLKQuaternionIdentity

    deinit {
        tearDownGL()
    }

    init(context: EAGLContext, world: World) {
        self.context = context
        self.world = world

        super.init()

        setUpModels()
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

        for (index, model) in gaugeModels.enumerate() {
            if let gauge = model as? GaugeModel {
                gauge.position = GLKVector3Add(GLKVector3Make(0, 0.075, 0), GLKVector3Make(0, 0.015 * Float(index + 1), 0))
            }
        }

        countLabelModel.position = GLKVector3Make(-0.495, 0.28, 0)
        countLabelModel.size = 0.35
        countLabelModel.horizontalAlign = .Left
        countLabelModel.verticalAlign = .Bottom
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

        guard let whiteTextureFilePath = NSBundle.mainBundle().pathForResource("white", ofType: "png") else {
            fatalError("file not found white.png")
        }
        whiteTextureInfo = try! GLKTextureLoader.textureWithContentsOfFile(whiteTextureFilePath, options: nil)
        font.loadTexture()
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

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), modelVertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(ModelVertex.size * modelVertices.count), vertices, GLenum(GL_STATIC_DRAW))

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
        if (animationProgress < 1.0) {
            animationProgress = min(1.0, animationProgress + Float(timeSinceLastUpdate) * 4)
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

        glBindTexture(GLenum(GL_TEXTURE_2D), font.textureInfo.name)
        renderModels(labelObjects)

        glDisable(GLenum(GL_DEPTH_TEST))

        glUseProgram(uiShaderProgram.programID)

        uiShaderProgram.projectionMatrix = projectionMatrix

        glBindTexture(GLenum(GL_TEXTURE_2D), whiteTextureInfo.name)
        renderModels(uiObjects)

        glBindTexture(GLenum(GL_TEXTURE_2D), font.textureInfo.name)
        renderModels(uiLabelObjects)
    }
}
