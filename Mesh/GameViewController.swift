import GLKit
import OpenGLES

var vertices: [GLfloat] = [
    -0.5, -0.5, 0.0,
    -0.5,  0.5, 0.0,
     0.5, -0.5, 0.0,
     0.5,  0.5, 0.0,
]

class GameViewController: GLKViewController {
    var vertexBufferID: GLuint = 0
    var context: EAGLContext!
    var effect: GLKBaseEffect!

    deinit {
        EAGLContext.setCurrentContext(self.context)

        if (vertexBufferID != 0) {
            glDeleteBuffers(1, &vertexBufferID)
        }

        self.context = nil
        EAGLContext.setCurrentContext(nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.context = EAGLContext(API: .OpenGLES2)

        let view = self.view as! GLKView
        view.context = self.context

        self.setUpGL()
    }

    func setUpGL() {
        EAGLContext.setCurrentContext(self.context)

        let effect = GLKBaseEffect()
        effect.useConstantColor = GLboolean(GL_TRUE)
        effect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        self.effect = effect

        glClearColor(0.0, 0.0, 0.0, 1.0)

        glGenBuffers(1, &vertexBufferID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferID)

        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(sizeof(GLfloat) * vertices.count), &vertices, GLenum(GL_STATIC_DRAW))

        let attrib = GLuint(GLKVertexAttrib.Position.rawValue)
        glEnableVertexAttribArray(attrib)
        glVertexAttribPointer(attrib, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(GLfloat) * 3), nil)
    }

    // MARK: - GLKViewDelegate methods

    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        self.effect.prepareToDraw()

        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLsizei(sizeof(GLfloat) * vertices.count))
    }
}
