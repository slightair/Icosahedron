import GLKit

func BUFFER_OFFSET(i: Int) -> UnsafePointer<Void> {
    let p: UnsafePointer<Void> = nil
    return p.advancedBy(i)
}

class BlurCanvas {
    let vertices: [Float] = [
        -1.0, -1.0, 0.0, 1.0, 1.0, 1.0, 1.0,
        -1.0,  1.0, 0.0, 1.0, 1.0, 1.0, 1.0,
         1.0, -1.0, 0.0, 1.0, 1.0, 1.0, 1.0,
         1.0,  1.0, 0.0, 1.0, 1.0, 1.0, 1.0,
    ]

    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0

    func prepare() {
        glGenVertexArrays(1, &vertexArray)
        glBindVertexArray(vertexArray)

        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)

        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(sizeof(Float) * vertices.count), vertices, GLenum(GL_STATIC_DRAW))

        let stride = GLsizei(sizeof(Float) * 7)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, BUFFER_OFFSET(0))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, BUFFER_OFFSET(sizeof(Float) * 3))

        glBindVertexArray(0)
    }

    func render(program: BlurShaderProgram, sourceTexture: GLuint) {
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), sourceTexture)
        program.sourceTexture = 0

        glBindVertexArray(vertexArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
    }
}
