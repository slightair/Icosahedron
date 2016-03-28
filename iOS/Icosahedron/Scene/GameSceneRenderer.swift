import GLKit

class GameSceneRenderer: BaseRenderer {
    var backgroundShaderProgram: BackgroundShaderProgram!
    var modelShaderProgram: ModelShaderProgram!
    var particleShaderProgram: ParticleShaderProgram!
    var canvasShaderProgram: CanvasShaderProgram!
    var uiShaderProgram: UIShaderProgram!

    let world: World
    let modelProducer: GameSceneModelProducer
    let canvasModel = CanvasModel()

    var prevVertex: IcosahedronVertex!
    var currentVertex: IcosahedronVertex!
    var prevQuaternion = GLKQuaternionIdentity
    var currentQuaternion = GLKQuaternionIdentity
    var billboardQuaternion = GLKQuaternionIdentity

    var movingProgress: Float = 1.0 {
        didSet {
            if prevVertex != nil && currentVertex != nil {
                let markerPosition = GLKVector3Lerp(prevVertex.coordinate, currentVertex.coordinate, movingProgress)
                modelProducer.markerModel.setPosition(markerPosition, prevPosition: prevVertex.coordinate)
            }
        }
    }

    init(world: World) {
        self.world = world
        self.modelProducer = GameSceneModelProducer(world: world)

        super.init()

        currentVertex = modelProducer.icosahedronModel.pointDict[.C]

        let dummyVertex = modelProducer.icosahedronModel.pointDict[.F]!
        modelProducer.markerModel.setPosition(currentVertex.coordinate, prevPosition: dummyVertex.coordinate)

        update()
    }

    override func setUp() {
        super.setUp()

        backgroundShaderProgram = BackgroundShaderProgram()
        modelShaderProgram = ModelShaderProgram()
        particleShaderProgram = ParticleShaderProgram()
        canvasShaderProgram = CanvasShaderProgram()
        uiShaderProgram = UIShaderProgram()
    }

    private func moveToVertex(vertex: IcosahedronVertex) {
        prevVertex = currentVertex
        currentVertex = vertex

        let relativeQuaternion = quaternionForRotate(from: currentVertex.coordinate, to: prevVertex.coordinate)

        prevQuaternion = currentQuaternion
        currentQuaternion = GLKQuaternionMultiply(currentQuaternion, relativeQuaternion)
    }

    private func renderBackground() {
        glEnable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(backgroundShaderProgram.programID)
        backgroundShaderProgram.projectionMatrix = backgroundProjectionMatrix
        backgroundShaderProgram.worldMatrix = backgroundWorldMatrix
        backgroundShaderProgram.normalMatrix = backgroundNormalMatrix

        var time = CFAbsoluteTimeGetCurrent()
        time -= floor(time)

        let backgroundMeshTextureInfo = TextureSet.sharedSet[.BackgroundMesh]
        glBindTexture(GLenum(GL_TEXTURE_2D), backgroundMeshTextureInfo.name)
        backgroundShaderProgram.time = GLfloat(time)
        drawModels(modelProducer.backgroundModelObjects())
    }

    private func renderModels() {
        glEnable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(modelShaderProgram.programID)
        modelShaderProgram.projectionMatrix = modelProjectionMatrix
        modelShaderProgram.worldMatrix = worldMatrix
        modelShaderProgram.normalMatrix = normalMatrix

        let whiteTextureInfo = TextureSet.sharedSet[.White]
        glBindTexture(GLenum(GL_TEXTURE_2D), whiteTextureInfo.name)
        drawModels(modelProducer.modelObjects())

        glBindTexture(GLenum(GL_TEXTURE_2D), FontData.defaultData.textureInfo.name)
        drawModels(modelProducer.labelObjects().map { $0 as Renderable})

        let icosahedronMeshTextureInfo = TextureSet.sharedSet[.IcosahedronMesh]
        glBindTexture(GLenum(GL_TEXTURE_2D), icosahedronMeshTextureInfo.name)
        drawModels([modelProducer.icosahedronModel])

        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE))

        let pointTextureInfo = TextureSet.sharedSet[.Point]
        glBindTexture(GLenum(GL_TEXTURE_2D), pointTextureInfo.name)
        drawModels(modelProducer.trackObjects())
    }

    private func renderParticles() {
        glDisable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE))

        glUseProgram(particleShaderProgram.programID)
        particleShaderProgram.projectionMatrix = modelProjectionMatrix
        particleShaderProgram.worldMatrix = worldMatrix

        let pointTextureInfo = TextureSet.sharedSet[.Point]
        glBindTexture(GLenum(GL_TEXTURE_2D), pointTextureInfo.name)
        drawParticle(modelProducer.particlePoints())
    }

    private func renderCanvas() {
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

    private func renderUI() {
        glDisable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(uiShaderProgram.programID)
        uiShaderProgram.projectionMatrix = modelProjectionMatrix

        let symbolTextureInfo = TextureSet.sharedSet[.SymbolIcon]
        glBindTexture(GLenum(GL_TEXTURE_2D), symbolTextureInfo.name)
        drawModels(modelProducer.uiSymbolObjects())

        let whiteTextureInfo = TextureSet.sharedSet[.White]
        glBindTexture(GLenum(GL_TEXTURE_2D), whiteTextureInfo.name)
        drawModels(modelProducer.uiObjects())

        glBindTexture(GLenum(GL_TEXTURE_2D), FontData.defaultData.textureInfo.name)
        drawModels(modelProducer.uiLabelObjects())
    }

    func render() {
        var defaultFrameBufferObject: GLint = 0
        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &defaultFrameBufferObject)

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), modelFrameBuffer)

        let buffers = [
            GLenum(GL_COLOR_ATTACHMENT0),
        ]
        glDrawBuffers(1, buffers)

        glClearColor(0.0, 0.0, 0.0, 0.0)
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

    func update(timeSinceLastUpdate: NSTimeInterval = 0) {
        modelProducer.update(timeSinceLastUpdate)

        let baseQuaternion = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(150), 1.0, 0.0, 0.0)
        let movingQuaternion = GLKQuaternionSlerp(prevQuaternion, currentQuaternion, movingProgress)
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

    func rotateModelWithTappedLocation(location: CGPoint) {
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
}
