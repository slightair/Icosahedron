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

    var modelFrameBuffer: GLuint = 0
    var modelColorTexture: GLuint = 0
    var modelDepthRenderBuffer: GLuint = 0

    var modelShaderProgram: ModelShaderProgram!
    var particleShaderProgram: ParticleShaderProgram!
    var canvasShaderProgram: CanvasShaderProgram!
    var uiShaderProgram: UIShaderProgram!

    var backgroundProjectionMatrix = GLKMatrix4Identity
    var backgroundWorldMatrix = GLKMatrix4Identity
    var backgroundNormalMatrix = GLKMatrix3Identity

    var modelProjectionMatrix = GLKMatrix4Identity
    var worldMatrix = GLKMatrix4Identity
    var normalMatrix = GLKMatrix3Identity

    let fontData: FontData = FontData.defaultData
    var meshTextureInfo: GLKTextureInfo!
    var whiteTextureInfo: GLKTextureInfo!
    var pointTextureInfo: GLKTextureInfo!

    let world: World
    let modelProducer: GameSceneModelProducer
    let canvasModel = CanvasModel()
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
        particleShaderProgram = ParticleShaderProgram()
        canvasShaderProgram = CanvasShaderProgram()
        uiShaderProgram = UIShaderProgram()

        let projectionWidth: Float = 1.0
        let projectionHeight = projectionWidth / Screen.aspect
        modelProjectionMatrix = GLKMatrix4MakeOrtho(-projectionWidth / 2, projectionWidth / 2, -projectionHeight / 2, projectionHeight / 2, 0.1, 10)
        backgroundProjectionMatrix = GLKMatrix4MakePerspective(120, Screen.aspect, 0.1, 10)

        glGenVertexArrays(1, &modelVertexArray)
        glBindVertexArray(modelVertexArray)

        var buffers: [GLuint] = [GLuint](count: 2, repeatedValue: 0)
        glGenBuffers(2, &buffers)
        modelVertexBuffer = buffers[0]
        modelIndexBuffer = buffers[1]

        glBindVertexArray(0)

        guard let meshTextureAsset = NSDataAsset(name: "Mesh") else {
            fatalError("debug texture file not found")
        }
        meshTextureInfo = try! GLKTextureLoader.textureWithContentsOfData(meshTextureAsset.data, options: nil)

        guard let whiteTextureAsset = NSDataAsset(name: "White") else {
            fatalError("white texture file not found")
        }
        whiteTextureInfo = try! GLKTextureLoader.textureWithContentsOfData(whiteTextureAsset.data, options: nil)

        guard let pointTextureAsset = NSDataAsset(name: "Point") else {
            fatalError("point texture file not found")
        }
        pointTextureInfo = try! GLKTextureLoader.textureWithContentsOfData(pointTextureAsset.data, options: nil)

        fontData.loadTexture()

        let width = GLsizei(CGRectGetHeight(UIScreen.mainScreen().nativeBounds)) // long side
        let height = GLsizei(CGRectGetWidth(UIScreen.mainScreen().nativeBounds)) // short side

        glGenTextures(1, &modelColorTexture)
        glBindTexture(GLenum(GL_TEXTURE_2D), modelColorTexture)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA), width, height, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(GL_LINEAR))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_LINEAR))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_CLAMP_TO_EDGE))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_CLAMP_TO_EDGE))
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)

        glGenRenderbuffers(1, &modelDepthRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), modelDepthRenderBuffer)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT24), width, height)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), 0)

        glGenFramebuffers(1, &modelFrameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), modelFrameBuffer)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), modelColorTexture, 0)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), modelDepthRenderBuffer)
        guard glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) == GLenum(GL_FRAMEBUFFER_COMPLETE) else {
            fatalError("Check frame buffer status error!")
        }
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

    func tearDownGL() {
        glDeleteBuffers(1, &modelVertexBuffer)
        glDeleteBuffers(1, &modelIndexBuffer)
        glDeleteVertexArrays(1, &modelVertexArray)

        glDeleteTextures(1, &modelColorTexture)
        glDeleteRenderbuffers(1, &modelDepthRenderBuffer)
        glDeleteFramebuffers(1, &modelFrameBuffer)
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

    func drawPolygons(polygons: [RenderablePolygon]) {
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

        glDrawElements(GLenum(GL_TRIANGLE_STRIP), GLsizei(indexes.count), GLenum(GL_UNSIGNED_SHORT), nil)

        glBindVertexArray(0)
    }

    func drawModels(models: [Renderable]) {
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

    func drawParticle(points: [ParticleVertex]) {
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

        let backgroundBaseMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -2.0)
        backgroundWorldMatrix = GLKMatrix4Multiply(backgroundBaseMatrix, GLKMatrix4MakeWithQuaternion(worldQuaternion))
        backgroundNormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(backgroundWorldMatrix), nil)
    }

    func renderBackground() {
        glEnable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(modelShaderProgram.programID)
        modelShaderProgram.projectionMatrix = backgroundProjectionMatrix
        modelShaderProgram.worldMatrix = backgroundWorldMatrix
        modelShaderProgram.normalMatrix = backgroundNormalMatrix

        glBindTexture(GLenum(GL_TEXTURE_2D), meshTextureInfo.name)
        drawPolygons(modelProducer.polygons())
    }

    func renderModels() {
        glEnable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(modelShaderProgram.programID)
        modelShaderProgram.projectionMatrix = modelProjectionMatrix
        modelShaderProgram.worldMatrix = worldMatrix
        modelShaderProgram.normalMatrix = normalMatrix

        glBindTexture(GLenum(GL_TEXTURE_2D), whiteTextureInfo.name)
        drawModels(modelProducer.modelObjects())

        glBindTexture(GLenum(GL_TEXTURE_2D), fontData.textureInfo.name)
        drawModels(modelProducer.labelObjects().map { $0 as Renderable})
    }

    func renderParticles() {
        glDisable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE))

        glUseProgram(particleShaderProgram.programID)
        particleShaderProgram.projectionMatrix = modelProjectionMatrix
        particleShaderProgram.worldMatrix = worldMatrix

        glBindTexture(GLenum(GL_TEXTURE_2D), pointTextureInfo.name)
        drawParticle(modelProducer.particlePoints())
    }

    func renderCanvas() {
        glDisable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(canvasShaderProgram.programID)

        var time = CFAbsoluteTimeGetCurrent()
        time -= floor(time)

        let width = Float(CGRectGetHeight(UIScreen.mainScreen().nativeBounds)) // long side
        let height = Float(CGRectGetWidth(UIScreen.mainScreen().nativeBounds)) // short side
        let numBlockHorizontal: Float = 64
        let numBlockVertical: Float = 256

        glBindTexture(GLenum(GL_TEXTURE_2D), modelColorTexture)
        canvasShaderProgram.textureSize = GLKVector2Make(width, height)
        canvasShaderProgram.blockSize = GLKVector2Make(width / numBlockHorizontal, height / numBlockVertical)
        canvasShaderProgram.noiseFactor = modelProducer.noiseFactor
        canvasShaderProgram.effectColor = modelProducer.effectColor
        canvasShaderProgram.effectColorFactor = modelProducer.effectColorFactor
        canvasShaderProgram.time = GLfloat(time)

        drawPolygons([canvasModel])
    }

    func renderUI() {
        glDisable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(uiShaderProgram.programID)
        uiShaderProgram.projectionMatrix = modelProjectionMatrix

        glBindTexture(GLenum(GL_TEXTURE_2D), whiteTextureInfo.name)
        drawModels(modelProducer.uiObjects())

        glBindTexture(GLenum(GL_TEXTURE_2D), fontData.textureInfo.name)
        drawModels(modelProducer.uiLabelObjects())
    }

    // MARK: - GLKView delegate methods

    func glkView(view: GLKView, drawInRect rect: CGRect) {
        var defaultFrameBufferObject: GLint = 0
        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &defaultFrameBufferObject)

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), modelFrameBuffer)

        let buffers = [
            GLenum(GL_COLOR_ATTACHMENT0),
        ]
        glDrawBuffers(1, buffers)

        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))

        glEnable(GLenum(GL_BLEND))
        glActiveTexture(GLenum(GL_TEXTURE0))

        renderBackground()
        renderModels()
        renderParticles()

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(defaultFrameBufferObject))

        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        renderCanvas()
        renderUI()
    }
}
