import GLKit

class TetrahedronModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity

    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0

    var modelVertices: [ModelVertex]
    var vertices: [Float] {
        return modelVertices.flatMap { $0.v }
    }
    let topCoordinate: GLKVector3

    init() {
        let scale: Float = 0.02

        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1, 1, 1), scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make( 1,-1,-1), scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make(-1, 1,-1), scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-1,-1, 1), scale)

        let normalDCB = createFaceNormal(coordD, y: coordC, z: coordB)
        let normalCAB = createFaceNormal(coordC, y: coordA, z: coordB)
        let normalCDA = createFaceNormal(coordC, y: coordD, z: coordA)
        let normalBAD = createFaceNormal(coordB, y: coordA, z: coordD)

        let faceColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)

        modelVertices = [
            ModelVertex(position: coordD, normal: normalDCB, color: faceColor),
            ModelVertex(position: coordC, normal: normalDCB, color: faceColor),
            ModelVertex(position: coordB, normal: normalDCB, color: faceColor),

            ModelVertex(position: coordC, normal: normalCAB, color: faceColor),
            ModelVertex(position: coordA, normal: normalCAB, color: faceColor),
            ModelVertex(position: coordB, normal: normalCAB, color: faceColor),

            ModelVertex(position: coordC, normal: normalCDA, color: faceColor),
            ModelVertex(position: coordD, normal: normalCDA, color: faceColor),
            ModelVertex(position: coordA, normal: normalCDA, color: faceColor),

            ModelVertex(position: coordB, normal: normalBAD, color: faceColor),
            ModelVertex(position: coordA, normal: normalBAD, color: faceColor),
            ModelVertex(position: coordD, normal: normalBAD, color: faceColor),
        ]

        topCoordinate = coordA
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
        program.modelMatrix = modelMatrix
        program.useTexture = false

        glBindVertexArray(vertexArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(modelVertices.count))
    }
}
