import GLKit

class TetrahedronModel: Renderable {
    var position: GLKVector3
    var modelMatrix = GLKMatrix4Identity
    var quaternion = GLKQuaternionIdentity
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0

    var modelVertices: [ModelVertex]
    var vertices: [Float] {
        return modelVertices.flatMap { $0.v }
    }

    func createFaceNormal(x: GLKVector3, y: GLKVector3, z: GLKVector3) -> GLKVector3 {
        return GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(x, y), GLKVector3Subtract(y, z)))
    }

    init(initPosition: GLKVector3) {
        position = initPosition

        let scale: Float = 0.02

        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1, 1, 1), scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make( 1,-1,-1), scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make(-1, 1,-1), scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-1,-1, 1), scale)

        let pointColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)

        modelVertices = [
            ModelVertex(position: coordD, normal: coordD, color: pointColor),
            ModelVertex(position: coordB, normal: coordB, color: pointColor),
            ModelVertex(position: coordC, normal: coordC, color: pointColor),
            ModelVertex(position: coordA, normal: coordA, color: pointColor),
            ModelVertex(position: coordD, normal: coordD, color: pointColor),
            ModelVertex(position: coordB, normal: coordB, color: pointColor),
        ]
    }

    deinit {
        glDeleteBuffers(1, &vertexBuffer)
        glDeleteVertexArrays(1, &vertexArray)
    }

    func prepare() {
        glGenVertexArrays(1, &vertexArray)
        glBindVertexArray(vertexArray)

        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)

        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(ModelVertex.size * modelVertices.count), vertices, GLenum(GL_STATIC_DRAW))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(0))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(sizeof(Float) * 3))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(sizeof(Float) * 6))

        glBindVertexArray(0)
    }

    func render(program: ModelShaderProgram) {
        let translationMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z)
        program.modelMatrix = GLKMatrix4Multiply(modelMatrix, translationMatrix)
        program.useTexture = false

        glBindVertexArray(vertexArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLsizei(modelVertices.count))
    }
}
