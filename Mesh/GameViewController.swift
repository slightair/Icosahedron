import GLKit
import OpenGLES

func BUFFER_OFFSET(i: Int) -> UnsafePointer<Void> {
    let p: UnsafePointer<Void> = nil
    return p.advancedBy(i)
}

protocol GLfloatValueContainer {
    var values: [GLfloat] { get }
}

struct Vertex: GLfloatValueContainer {
    let position: GLKVector3
    let color: GLKVector4

    static var size: GLint {
        return GLint(sizeof(GLKVector3) + sizeof(GLKVector4))
    }

    var values: [GLfloat] {
        return [
            position.x, position.y, position.z,
            color.r, color.g, color.b, color.a,
        ]
    }
}

extension CollectionType where Generator.Element: GLfloatValueContainer {
    func GLfloatValues() -> [GLfloat] {
        return self.flatMap { $0.values }
    }
}

let red = GLKVector4Make(1.0, 0.0, 0.0, 1.0)
let blue = GLKVector4Make(0.0, 0.0, 1.0, 1.0)

var vertices: [Vertex] = [
    Vertex(position: GLKVector3Make(-0.5, -0.5, 0.0), color: red),
    Vertex(position: GLKVector3Make(-0.5,  0.5, 0.0), color: red),
    Vertex(position: GLKVector3Make( 0.5, -0.5, 0.0), color: red),
    Vertex(position: GLKVector3Make( 0.5, -0.5, 0.0), color: blue),
    Vertex(position: GLKVector3Make( 0.5,  0.5, 0.0), color: blue),
    Vertex(position: GLKVector3Make(-0.5,  0.5, 0.0), color: blue),
]

var indices: [GLubyte] = [
    0, 1, 2,
    3, 4, 5,
]

class GameViewController: GLKViewController {
    var vertexBufferID: GLuint = 0
    var indexBufferID: GLuint = 0
    var context: EAGLContext!
    var effect: GLKBaseEffect!

    deinit {
        EAGLContext.setCurrentContext(self.context)

        if (vertexBufferID != 0) {
            glDeleteBuffers(1, &vertexBufferID)
        }

        if (indexBufferID != 0) {
            glDeleteBuffers(1, &indexBufferID)
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
    }

    // MARK: - GLKViewDelegate methods

    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        self.effect.prepareToDraw()

        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        var triangles = vertices.GLfloatValues()

        glGenBuffers(1, &vertexBufferID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(sizeof(GLfloat) * triangles.count), &triangles, GLenum(GL_STATIC_DRAW))

        glGenBuffers(1, &indexBufferID)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBufferID)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(sizeof(GLubyte) * indices.count), &indices, GLenum(GL_STATIC_DRAW))

        let positionAttrib = GLuint(GLKVertexAttrib.Position.rawValue)
        let colorAttrib = GLuint(GLKVertexAttrib.Color.rawValue)

        glEnableVertexAttribArray(positionAttrib)
        glEnableVertexAttribArray(colorAttrib)

        glVertexAttribPointer(positionAttrib, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(Vertex.size), BUFFER_OFFSET(0))
        glVertexAttribPointer(colorAttrib, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(Vertex.size), BUFFER_OFFSET(sizeof(GLKVector3)))

        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
    }
}
