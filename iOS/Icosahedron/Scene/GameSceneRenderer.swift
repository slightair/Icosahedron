import GLKit
import OpenGLES

protocol GameSceneRendererDelegate {
    func didChangeIcosahedronPoint(point: Icosahedron.Point)
}

class GameSceneRenderer: NSObject, GLKViewDelegate {
    let context: EAGLContext

    var modelVertexArray: GLuint = 0
    var modelVertexBuffer: GLuint = 0
    var modelIndexBuffer: GLuint = 0

    var modelShaderProgram: ModelShaderProgram!
    var uiShaderProgram: UIShaderProgram!
    var particleShaderProgram: ParticleShaderProgram!

    var projectionMatrix = GLKMatrix4Identity
    var worldMatrix = GLKMatrix4Identity
    var normalMatrix = GLKMatrix3Identity

    let fontData: FontData = FontData.defaultData
    var whiteTextureInfo: GLKTextureInfo!
    var pointTextureInfo: GLKTextureInfo!

    let world: World
    let modelProducer: GameSceneModelProducer
    var delegate: GameSceneRendererDelegate?

    var prevVertex: IcosahedronVertex!
    var currentVertex: IcosahedronVertex!
    var prevQuaternion = GLKQuaternionIdentity
    var currentQuaternion = GLKQuaternionIdentity
    var billboardQuaternion = GLKQuaternionIdentity

    var animationProgress: Float = 1.0 {
        didSet {
            if prevVertex != nil && currentVertex != nil {
                let markerPosition = GLKVector3Lerp(prevVertex.coordinate, currentVertex.coordinate, animationProgress)
                modelProducer.markerModel.setPosition(markerPosition, prevPosition: prevVertex.coordinate)

                if animationProgress == 1.0 {
                    delegate?.didChangeIcosahedronPoint(currentVertex.point)
                }
            }
        }
    }

    deinit {
        tearDownGL()
    }

    init(context: EAGLContext, world: World) {
        self.context = context
        self.world = world
        self.modelProducer = GameSceneModelProducer(world: world)

        super.init()

        currentVertex = modelProducer.icosahedronModel.pointDict[.C]

        let dummyVertex = modelProducer.icosahedronModel.pointDict[.F]!
        modelProducer.markerModel.setPosition(currentVertex.coordinate, prevPosition: dummyVertex.coordinate)

        setUpGL()

        update()
    }

    func setUpGL() {
        EAGLContext.setCurrentContext(context)

        modelShaderProgram = ModelShaderProgram()
        uiShaderProgram = UIShaderProgram()
        particleShaderProgram = ParticleShaderProgram()

        let projectionWidth: Float = 1.0
        let projectionHeight = projectionWidth / Screen.aspect
        projectionMatrix = GLKMatrix4MakeOrtho(-projectionWidth / 2, projectionWidth / 2, -projectionHeight / 2, projectionHeight / 2, 0.1, 100)

        glGenVertexArrays(1, &modelVertexArray)
        glBindVertexArray(modelVertexArray)

        var buffers: [GLuint] = [GLuint](count: 2, repeatedValue: 0)
        glGenBuffers(2, &buffers)
        modelVertexBuffer = buffers[0]
        modelIndexBuffer = buffers[1]

        glBindVertexArray(0)

        guard let whiteTextureAsset = NSDataAsset(name: "White") else {
            fatalError("white texture file not found")
        }
        whiteTextureInfo = try! GLKTextureLoader.textureWithContentsOfData(whiteTextureAsset.data, options: nil)

        guard let pointTextureAsset = NSDataAsset(name: "Point") else {
            fatalError("point texture file not found")
        }
        pointTextureInfo = try! GLKTextureLoader.textureWithContentsOfData(pointTextureAsset.data, options: nil)

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

    func renderPolygons(polygons: [RenderablePolygon]) {
        let modelVertices = polygons.flatMap { $0.modelVertices }
        let vertices: [Float] = modelVertices.flatMap { $0.v }
        let indexes: [GLushort] = polygons.flatMap { $0.modelIndexes }

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

        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), modelIndexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(sizeof(GLushort) * indexes.count), indexes, GLenum(GL_STREAM_DRAW))

        glDrawElements(GLenum(GL_LINE_STRIP), GLsizei(indexes.count), GLenum(GL_UNSIGNED_SHORT), nil)

        glBindVertexArray(0)
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

    func renderParticle(points: [ParticleVertex]) {
        let vertices: [Float] = points.flatMap { $0.v }

        glBindVertexArray(modelVertexArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), modelVertexBuffer)

        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(ParticleVertex.size * points.count), vertices, GLenum(GL_STREAM_DRAW))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ParticleVertex.size), BUFFER_OFFSET(0))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ParticleVertex.size), BUFFER_OFFSET(sizeof(Float) * 3))

        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(points.count))

        glBindVertexArray(0)
    }

    func update(timeSinceLastUpdate: NSTimeInterval = 0) {
        if animationProgress < 1.0 {
            animationProgress = min(1.0, animationProgress + Float(timeSinceLastUpdate) * 4)
        }

        modelProducer.update(timeSinceLastUpdate)

        let baseQuaternion = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(150), 1.0, 0.0, 0.0)
        let movingQuaternion = GLKQuaternionSlerp(prevQuaternion, currentQuaternion, animationProgress)
        let worldQuaternion = GLKQuaternionMultiply(baseQuaternion, movingQuaternion)
        billboardQuaternion = GLKQuaternionInvert(movingQuaternion)

        let baseMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -1.0)
        worldMatrix = GLKMatrix4Multiply(baseMatrix, GLKMatrix4MakeWithQuaternion(worldQuaternion))
        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(worldMatrix), nil)

        for label in modelProducer.labelObjects() {
            label.quaternion = billboardQuaternion
        }
    }

    // MARK: - GLKView delegate methods

    func glkView(view: GLKView, drawInRect rect: CGRect) {
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))

        glEnable(GLenum(GL_BLEND))

        // Render Models

        glEnable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(modelShaderProgram.programID)

        modelShaderProgram.projectionMatrix = projectionMatrix
        modelShaderProgram.worldMatrix = worldMatrix
        modelShaderProgram.normalMatrix = normalMatrix

        glActiveTexture(GLenum(GL_TEXTURE0))

        glBindTexture(GLenum(GL_TEXTURE_2D), whiteTextureInfo.name)

        renderPolygons(modelProducer.polygons())
        renderModels(modelProducer.modelObjects())

        glBindTexture(GLenum(GL_TEXTURE_2D), fontData.textureInfo.name)
        renderModels(modelProducer.labelObjects().map { $0 as Renderable})

        // Render Particles

        glDisable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE))

        glUseProgram(particleShaderProgram.programID)

        particleShaderProgram.projectionMatrix = projectionMatrix
        particleShaderProgram.worldMatrix = worldMatrix

        glBindTexture(GLenum(GL_TEXTURE_2D), pointTextureInfo.name)
        renderParticle(modelProducer.particlePoints())

        // Render UI

        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(uiShaderProgram.programID)

        uiShaderProgram.projectionMatrix = projectionMatrix

        glBindTexture(GLenum(GL_TEXTURE_2D), whiteTextureInfo.name)
        renderModels(modelProducer.uiObjects())

        glBindTexture(GLenum(GL_TEXTURE_2D), fontData.textureInfo.name)
        renderModels(modelProducer.uiLabelObjects())
    }
}
