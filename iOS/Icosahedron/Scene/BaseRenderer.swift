import GLKit

class BaseRenderer {
    var modelVertexArray: GLuint = 0
    var modelVertexBuffer: GLuint = 0
    var modelIndexBuffer: GLuint = 0

    var modelFrameBuffer: GLuint = 0
    var modelColorTexture: GLuint = 0
    var modelDepthRenderBuffer: GLuint = 0

    var modelProjectionMatrix = GLKMatrix4Identity
    var worldMatrix = GLKMatrix4Identity
    var normalMatrix = GLKMatrix3Identity

    var backgroundProjectionMatrix = GLKMatrix4Identity
    var backgroundWorldMatrix = GLKMatrix4Identity
    var backgroundNormalMatrix = GLKMatrix3Identity

    deinit {
        tearDownGL()
    }

    init() {
        setUp()
    }

    func setUpGL() {
        let projectionWidth: Float = 1.0
        let projectionHeight = projectionWidth / Screen.aspect
        modelProjectionMatrix = GLKMatrix4MakeOrtho(-projectionWidth / 2, projectionWidth / 2, -projectionHeight / 2, projectionHeight / 2, 0.1, 10)
        backgroundProjectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(30), Screen.aspect, 0.1, 10)

        glGenVertexArrays(1, &modelVertexArray)
        glBindVertexArray(modelVertexArray)

        var buffers: [GLuint] = [GLuint](count: 2, repeatedValue: 0)
        glGenBuffers(2, &buffers)
        modelVertexBuffer = buffers[0]
        modelIndexBuffer = buffers[1]

        glBindVertexArray(0)

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

    func setUp() {
        setUpGL()
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

        glEnableVertexAttribArray(ParticleShaderProgram.PointSizeAttribLocation)
        glVertexAttribPointer(ParticleShaderProgram.PointSizeAttribLocation, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ParticleVertex.size), BUFFER_OFFSET(sizeof(Float) * 7))

        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(points.count))

        glBindVertexArray(0)
    }
}
