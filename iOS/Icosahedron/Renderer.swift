import GLKit
import OpenGLES

class Renderer: NSObject, GLKViewDelegate {
    let context: EAGLContext

    var modelShaderProgram: ModelShaderProgram!
    var blurShaderProgram: BlurShaderProgram!

    let icosahedronModel = IcosahedronModel()
    var markerModel: TetrahedronModel!
    let blurCanvas = BlurCanvas()

    var projectionMatrix = GLKMatrix4Identity
    var worldMatrix = GLKMatrix4Identity
    var normalMatrix = GLKMatrix3Identity

    var modelFrameBufferObject: GLuint = 0
    var modelColorTexture: GLuint = 0
    var modelDepthRenderBufferObject: GLuint = 0
    var texelSize = GLKVector2Make(0, 0)
    var models: [Renderable] = []

    var prevVertex: IcosahedronVertex!
    var currentVertex: IcosahedronVertex!
    var prevQuaternion = GLKQuaternionIdentity
    var currentQuaternion = GLKQuaternionIdentity
    var animationProgress: Float = 1.0

    deinit {
        tearDownGL()
    }

    init(context: EAGLContext) {
        self.context = context

        super.init()

        currentVertex = icosahedronModel.vertices["C"]
        markerModel = TetrahedronModel(initPosition: currentVertex.coordinate)

        setUpGL()

        models.append(icosahedronModel)
        models.append(markerModel)

        update(0)
    }

    func setUpGL() {
        EAGLContext.setCurrentContext(context)

        modelShaderProgram = ModelShaderProgram()
        blurShaderProgram = BlurShaderProgram()

        blurCanvas.prepare()
        icosahedronModel.prepare()
        markerModel.prepare()

        let width = GLsizei(CGRectGetHeight(UIScreen.mainScreen().nativeBounds)) // long side
        let height = GLsizei(CGRectGetWidth(UIScreen.mainScreen().nativeBounds)) // short side
        texelSize = GLKVector2Make(1.0 / Float(width), 1.0 / Float(height))

        let aspect = Float(fabs(Double(width) / Double(height)))
        let projectionWidth: Float = 1.0
        let projectionHeight = projectionWidth / aspect
        projectionMatrix = GLKMatrix4MakeOrtho(-projectionWidth / 2, projectionWidth / 2, -projectionHeight / 2, projectionHeight / 2, 0.1, 100)

        glGenTextures(1, &modelColorTexture)
        glBindTexture(GLenum(GL_TEXTURE_2D), modelColorTexture)

        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA8), width, height, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)

        glBindTexture(GLenum(GL_TEXTURE_2D), 0)

        glGenRenderbuffers(1, &modelDepthRenderBufferObject)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), modelDepthRenderBufferObject)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT24), width, height)

        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), 0)

        glGenFramebuffers(1, &modelFrameBufferObject)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), modelFrameBufferObject)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), modelColorTexture, 0)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), modelDepthRenderBufferObject)

        guard glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) == GLenum(GL_FRAMEBUFFER_COMPLETE) else {
            fatalError("Check frame buffer status error!")
        }

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

    func tearDownGL() {
        EAGLContext.setCurrentContext(context)

        glDeleteTextures(1, &modelColorTexture)
        glDeleteRenderbuffers(1, &modelDepthRenderBufferObject)
        glDeleteFramebuffers(1, &modelFrameBufferObject)

        EAGLContext.setCurrentContext(nil)
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

    func moveToVertex(vertex: IcosahedronVertex) {
        prevVertex = currentVertex
        currentVertex = vertex
        animationProgress = 0.0

        let relativeQuaternion = quaternionForRotate(from: currentVertex, to: prevVertex)

        prevQuaternion = currentQuaternion
        currentQuaternion = GLKQuaternionMultiply(currentQuaternion, relativeQuaternion)
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        if (animationProgress < 1.0) {
            animationProgress += Float(timeSinceLastUpdate) * 4
            animationProgress = min(1.0, animationProgress)
        }

        let baseQuaternion = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(150), 1.0, 0.0, 0.0)
        let movingQuaternion = GLKQuaternionSlerp(prevQuaternion, currentQuaternion, animationProgress)
        let worldQuaternion = GLKQuaternionMultiply(baseQuaternion, movingQuaternion)

        let baseMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -1.0)
        worldMatrix = GLKMatrix4Multiply(baseMatrix, GLKMatrix4MakeWithQuaternion(worldQuaternion))
        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(worldMatrix), nil)
    }

    // MARK: - GLKView delegate methods

    func glkView(view: GLKView, drawInRect rect: CGRect) {
        var defaultFrameBufferObject: GLint = 0
        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &defaultFrameBufferObject)

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), modelFrameBufferObject)

        glEnable(GLenum(GL_DEPTH_TEST))

        let buffers = [
            GLenum(GL_COLOR_ATTACHMENT0),
        ]
        glDrawBuffers(1, buffers)

        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))

        glUseProgram(modelShaderProgram.programID)

        modelShaderProgram.projectionMatrix = projectionMatrix
        modelShaderProgram.worldMatrix = worldMatrix
        modelShaderProgram.normalMatrix = normalMatrix

        for model in models {
            model.render(modelShaderProgram)
        }

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(defaultFrameBufferObject))

        glDisable(GLenum(GL_DEPTH_TEST))
        glDisable(GLenum(GL_BLEND))

        glUseProgram(blurShaderProgram.programID)

        blurShaderProgram.texelSize = texelSize
        blurShaderProgram.useBlur = false

        blurCanvas.render(blurShaderProgram, sourceTexture: modelColorTexture)

        glBindVertexArray(0)
    }
}
