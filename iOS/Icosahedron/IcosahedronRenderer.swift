import GLKit
import OpenGLES

func BUFFER_OFFSET(i: Int) -> UnsafePointer<Void> {
    let p: UnsafePointer<Void> = nil
    return p.advancedBy(i)
}

class IcosahedronRenderer: NSObject, GLKViewDelegate {
    enum Program: Int {
        case Model
        case Blur

        static var count: Int {
            return [Model, Blur].count
        }
    }

    enum ModelShaderUniform: Int {
        case ModelViewProjectionMatrix
        case NormalMatrix
        case VertexTexture
        case UseTexture

        static var count: Int {
            return [ModelViewProjectionMatrix, NormalMatrix, VertexTexture, UseTexture].count
        }
    }

    enum BlurShaderUniform: Int {
        case SourceTexture
        case TexelSize
        case UseBlur

        static var count: Int {
            return [SourceTexture, TexelSize, UseBlur].count
        }
    }

    enum VertexArray: Int {
        case ModelPoints
        case ModelLines
        case Canvas

        static var count: Int {
            return [ModelPoints, ModelLines, Canvas].count
        }
    }

    var programs = [GLuint](count: Program.count, repeatedValue: 0)
    var modelShaderUniforms = [GLint](count: ModelShaderUniform.count, repeatedValue: 0)
    var blurShaderUniforms = [GLint](count: BlurShaderUniform.count, repeatedValue: 0)
    var vertexArrays = [GLuint](count: VertexArray.count, repeatedValue: 0)
    var vertexBufferObjects = [GLuint](count: VertexArray.count, repeatedValue: 0)

    let context: EAGLContext
    let icosahedronModel = IcosahedronModel()
    var prevVertex: IcosahedronVertex!
    var currentVertex: IcosahedronVertex!
    var prevQuaternion = GLKQuaternionIdentity
    var currentQuaternion = GLKQuaternionIdentity
    var animationProgress: Float = 1.0
    var vertexTextureInfo: GLKTextureInfo!

    var projectionMatrix = GLKMatrix4Identity
    var modelViewProjectionMatrix = GLKMatrix4Identity
    var normalMatrix = GLKMatrix3Identity
    var modelFrameBufferObject: GLuint = 0
    var modelColorTexture: GLuint = 0
    var modelDepthRenderBufferObject: GLuint = 0
    var texelSize = GLKVector2Make(0, 0)

    deinit {
        tearDownGL()
    }

    init(context: EAGLContext) {
        self.context = context

        super.init()

        currentVertex = icosahedronModel.vertices["C"]

        setUpGL()

        do {
            let vertexTexturePath = NSBundle.mainBundle().pathForResource("vertex", ofType: "png")!
            vertexTextureInfo = try GLKTextureLoader.textureWithContentsOfFile(vertexTexturePath, options: nil)
        } catch {
            fatalError("Failed to load vertex texture")
        }
    }

    func setUpGL() {
        EAGLContext.setCurrentContext(context)

        setUpShaders()

        glGenVertexArrays(1, &vertexArrays[VertexArray.ModelPoints.rawValue])
        glGenVertexArrays(1, &vertexArrays[VertexArray.ModelLines.rawValue])
        glGenVertexArrays(1, &vertexArrays[VertexArray.Canvas.rawValue])

        setUpIcosahedronPoints()
        setUpIcosahedronLines()
        setUpCanvas()

        glBindVertexArray(0)

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

    func setUpShaders() {
        let modelProgramID = Program.Model.rawValue
        RenderUtils.loadShaders(&programs[modelProgramID], path: "ModelShader")
        modelShaderUniforms[ModelShaderUniform.ModelViewProjectionMatrix.rawValue] = glGetUniformLocation(programs[modelProgramID], "modelViewProjectionMatrix")
        modelShaderUniforms[ModelShaderUniform.NormalMatrix.rawValue] = glGetUniformLocation(programs[modelProgramID], "normalMatrix")
        modelShaderUniforms[ModelShaderUniform.VertexTexture.rawValue] = glGetUniformLocation(programs[modelProgramID], "vertexTexture")
        modelShaderUniforms[ModelShaderUniform.UseTexture.rawValue] = glGetUniformLocation(programs[modelProgramID], "useTexture")

        let blurProgramID = Program.Blur.rawValue
        RenderUtils.loadShaders(&programs[blurProgramID], path: "BlurShader")
        blurShaderUniforms[BlurShaderUniform.SourceTexture.rawValue] = glGetUniformLocation(programs[blurProgramID], "sourceTexture")
        blurShaderUniforms[BlurShaderUniform.TexelSize.rawValue] = glGetUniformLocation(programs[blurProgramID], "texelSize")
        blurShaderUniforms[BlurShaderUniform.UseBlur.rawValue] = glGetUniformLocation(programs[blurProgramID], "useBlur")
    }

    func setUpIcosahedronPoints() {
        let arrayID = VertexArray.ModelPoints.rawValue
        glBindVertexArray(vertexArrays[arrayID])
        glGenBuffers(1, &vertexBufferObjects[arrayID])
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferObjects[arrayID])
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(ModelVertex.size * IcosahedronModel.NumberOfPointVertices), icosahedronModel.pointVertices, GLenum(GL_STATIC_DRAW))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), ModelVertex.size, BUFFER_OFFSET(0))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), ModelVertex.size, BUFFER_OFFSET(sizeof(Float) * 3))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), ModelVertex.size, BUFFER_OFFSET(sizeof(Float) * 6))
    }

    func setUpIcosahedronLines() {
        let arrayID = VertexArray.ModelLines.rawValue
        glBindVertexArray(vertexArrays[arrayID])
        glGenBuffers(1, &vertexBufferObjects[arrayID])
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferObjects[arrayID])
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(ModelVertex.size * IcosahedronModel.NumberOfLineVertices), icosahedronModel.lineVertices, GLenum(GL_STATIC_DRAW))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), ModelVertex.size, BUFFER_OFFSET(0))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), ModelVertex.size, BUFFER_OFFSET(sizeof(Float) * 3))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), ModelVertex.size, BUFFER_OFFSET(sizeof(Float) * 6))
    }

    func setUpCanvas() {
        let vertices: [Float] = [
            -1.0, -1.0, 0.0, 0.1, 1.0, 1.0, 1.0,
            -1.0,  1.0, 0.0, 1.0, 1.0, 1.0, 1.0,
            1.0, -1.0, 0.0, 0.1, 1.0, 1.0, 1.0,
            1.0,  1.0, 0.0, 1.0, 1.0, 1.0, 1.0,
        ]

        let arrayID = VertexArray.Canvas.rawValue
        glBindVertexArray(vertexArrays[arrayID])
        glGenBuffers(1, &vertexBufferObjects[arrayID])
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferObjects[arrayID])
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(sizeof(Float) * vertices.count), vertices, GLenum(GL_STATIC_DRAW))

        let stride = GLsizei(sizeof(Float) * 7)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, BUFFER_OFFSET(0))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, BUFFER_OFFSET(sizeof(Float) * 3))
    }

    func tearDownGL() {
        EAGLContext.setCurrentContext(context)

        glDeleteBuffers(GLsizei(VertexArray.count), vertexBufferObjects)
        glDeleteVertexArrays(GLsizei(VertexArray.count), vertexArrays)

        glDeleteTextures(1, &modelColorTexture)
        glDeleteRenderbuffers(1, &modelDepthRenderBufferObject)
        glDeleteFramebuffers(1, &modelFrameBufferObject)

        glDeleteProgram(programs[Program.Model.rawValue])
        glDeleteProgram(programs[Program.Blur.rawValue])

        EAGLContext.setCurrentContext(nil)
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        let baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -5.0)

        if (animationProgress < 1.0) {
            animationProgress += Float(timeSinceLastUpdate) * 4
            animationProgress = min(1.0, animationProgress)
        }

        let modelQuaternion = GLKQuaternionSlerp(prevQuaternion, currentQuaternion, animationProgress)

        var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, 0.0)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(150), 1.0, 0.0, 0.0)
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(modelQuaternion))
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix)

        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), nil)
        modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
    }

    func rotateModelWithTappedLocation(location: CGPoint) {
        let locationVector = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(modelViewProjectionMatrix, nil), GLKVector3Make(Float(location.x), Float(location.y), 0))

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

    // MARK: - GLKView delegate methods

    func glkView(view: GLKView, drawInRect rect: CGRect) {
        var defaultFrameBufferObject: GLint = 0
        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &defaultFrameBufferObject)

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), modelFrameBufferObject)

        glEnable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE))

        let buffers = [
            GLenum(GL_COLOR_ATTACHMENT0),
        ]
        glDrawBuffers(1, buffers)

        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))

        glUseProgram(programs[Program.Model.rawValue])

        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), vertexTextureInfo.name)

        withUnsafePointer(&modelViewProjectionMatrix, {
            glUniformMatrix4fv(modelShaderUniforms[ModelShaderUniform.ModelViewProjectionMatrix.rawValue], 1, 0, UnsafePointer($0))
        })
        withUnsafePointer(&normalMatrix, {
            glUniformMatrix3fv(modelShaderUniforms[ModelShaderUniform.NormalMatrix.rawValue], 1, 0, UnsafePointer($0))
        })
        glUniform1i(modelShaderUniforms[ModelShaderUniform.VertexTexture.rawValue], 0)

        glLineWidth(8)
        glUniform1i(modelShaderUniforms[ModelShaderUniform.UseTexture.rawValue], GL_FALSE)
        glBindVertexArray(vertexArrays[VertexArray.ModelLines.rawValue])
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferObjects[VertexArray.ModelLines.rawValue])
        glDrawArrays(GLenum(GL_LINES), 0, IcosahedronModel.NumberOfLineVertices)

        glUniform1i(modelShaderUniforms[ModelShaderUniform.UseTexture.rawValue], GL_TRUE)
        glBindVertexArray(vertexArrays[VertexArray.ModelPoints.rawValue])
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferObjects[VertexArray.ModelPoints.rawValue])
        glDrawArrays(GLenum(GL_POINTS), 0, IcosahedronModel.NumberOfPointVertices)

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(defaultFrameBufferObject))

        glDisable(GLenum(GL_DEPTH_TEST))
        glDisable(GLenum(GL_BLEND))

        glUseProgram(programs[Program.Blur.rawValue])

        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), modelColorTexture)
        glUniform1i(blurShaderUniforms[BlurShaderUniform.SourceTexture.rawValue], 0)
        withUnsafePointer(&texelSize, {
            glUniform2fv(blurShaderUniforms[BlurShaderUniform.TexelSize.rawValue], 1, UnsafePointer($0))
        })
        glUniform1i(blurShaderUniforms[BlurShaderUniform.UseBlur.rawValue], GL_TRUE)

        glBindVertexArray(vertexArrays[VertexArray.Canvas.rawValue])
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferObjects[VertexArray.Canvas.rawValue])
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)

        glBindVertexArray(0)
    }
}
