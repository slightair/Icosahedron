import GLKit

class IcosahedronModel: Renderable {
    let position = GLKVector3Make(0.0, 0.0, 0.0)
    let quaternion = GLKQuaternionIdentity

    var pointVertexArray: GLuint = 0
    var lineVertexArray: GLuint = 0
    var pointVertexBuffer: GLuint = 0
    var lineVertexBuffer: GLuint = 0

    var pointModelVertices: [ModelVertex]
    var lineModelVertices: [ModelVertex]
    var vertices: [String: IcosahedronVertex] = [:]
    var pointVertices: [Float] {
        return pointModelVertices.flatMap { $0.v }
    }
    var lineVertices: [Float] {
        return lineModelVertices.flatMap { $0.v }
    }
    var vertexTextureInfo: GLKTextureInfo!

    init() {
        let ratio: Float = (1.0 + sqrt(5.0)) / 2.0
        let scale: Float = 0.15

        let coordG = GLKVector3MultiplyScalar(GLKVector3Make( ratio,  0,  1), scale)
        let coordE = GLKVector3MultiplyScalar(GLKVector3Make( ratio,  0, -1), scale)
        let coordH = GLKVector3MultiplyScalar(GLKVector3Make(-ratio,  0,  1), scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-ratio,  0, -1), scale)
        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1,  ratio,  0), scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make(-1,  ratio,  0), scale)
        let coordK = GLKVector3MultiplyScalar(GLKVector3Make( 1, -ratio,  0), scale)
        let coordJ = GLKVector3MultiplyScalar(GLKVector3Make(-1, -ratio,  0), scale)
        let coordF = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1,  ratio), scale)
        let coordL = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1,  ratio), scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1, -ratio), scale)
        let coordI = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1, -ratio), scale)

        let pointColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        let lineColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)

        pointModelVertices = [
            ModelVertex(position: coordA, normal: coordA, color: pointColor),
            ModelVertex(position: coordB, normal: coordB, color: pointColor),
            ModelVertex(position: coordC, normal: coordC, color: pointColor),
            ModelVertex(position: coordD, normal: coordD, color: pointColor),
            ModelVertex(position: coordE, normal: coordE, color: pointColor),
            ModelVertex(position: coordF, normal: coordF, color: pointColor),
            ModelVertex(position: coordG, normal: coordG, color: pointColor),
            ModelVertex(position: coordH, normal: coordH, color: pointColor),
            ModelVertex(position: coordI, normal: coordI, color: pointColor),
            ModelVertex(position: coordJ, normal: coordJ, color: pointColor),
            ModelVertex(position: coordK, normal: coordK, color: pointColor),
            ModelVertex(position: coordL, normal: coordL, color: pointColor),
        ]

        lineModelVertices = [
            ModelVertex(position: coordA, normal: coordA, color: lineColor), ModelVertex(position: coordB, normal: coordB, color: lineColor),
            ModelVertex(position: coordA, normal: coordA, color: lineColor), ModelVertex(position: coordC, normal: coordC, color: lineColor),
            ModelVertex(position: coordA, normal: coordA, color: lineColor), ModelVertex(position: coordE, normal: coordE, color: lineColor),
            ModelVertex(position: coordA, normal: coordA, color: lineColor), ModelVertex(position: coordF, normal: coordF, color: lineColor),
            ModelVertex(position: coordA, normal: coordA, color: lineColor), ModelVertex(position: coordG, normal: coordG, color: lineColor),
            ModelVertex(position: coordB, normal: coordB, color: lineColor), ModelVertex(position: coordC, normal: coordC, color: lineColor),
            ModelVertex(position: coordB, normal: coordB, color: lineColor), ModelVertex(position: coordD, normal: coordD, color: lineColor),
            ModelVertex(position: coordB, normal: coordB, color: lineColor), ModelVertex(position: coordF, normal: coordF, color: lineColor),
            ModelVertex(position: coordB, normal: coordB, color: lineColor), ModelVertex(position: coordH, normal: coordH, color: lineColor),
            ModelVertex(position: coordC, normal: coordC, color: lineColor), ModelVertex(position: coordD, normal: coordD, color: lineColor),
            ModelVertex(position: coordC, normal: coordC, color: lineColor), ModelVertex(position: coordE, normal: coordE, color: lineColor),
            ModelVertex(position: coordC, normal: coordC, color: lineColor), ModelVertex(position: coordI, normal: coordI, color: lineColor),
            ModelVertex(position: coordD, normal: coordD, color: lineColor), ModelVertex(position: coordH, normal: coordH, color: lineColor),
            ModelVertex(position: coordD, normal: coordD, color: lineColor), ModelVertex(position: coordI, normal: coordI, color: lineColor),
            ModelVertex(position: coordD, normal: coordD, color: lineColor), ModelVertex(position: coordJ, normal: coordJ, color: lineColor),
            ModelVertex(position: coordE, normal: coordE, color: lineColor), ModelVertex(position: coordG, normal: coordG, color: lineColor),
            ModelVertex(position: coordE, normal: coordE, color: lineColor), ModelVertex(position: coordI, normal: coordI, color: lineColor),
            ModelVertex(position: coordE, normal: coordE, color: lineColor), ModelVertex(position: coordK, normal: coordK, color: lineColor),
            ModelVertex(position: coordF, normal: coordF, color: lineColor), ModelVertex(position: coordG, normal: coordG, color: lineColor),
            ModelVertex(position: coordF, normal: coordF, color: lineColor), ModelVertex(position: coordH, normal: coordH, color: lineColor),
            ModelVertex(position: coordF, normal: coordF, color: lineColor), ModelVertex(position: coordL, normal: coordL, color: lineColor),
            ModelVertex(position: coordG, normal: coordG, color: lineColor), ModelVertex(position: coordK, normal: coordK, color: lineColor),
            ModelVertex(position: coordG, normal: coordG, color: lineColor), ModelVertex(position: coordL, normal: coordL, color: lineColor),
            ModelVertex(position: coordH, normal: coordH, color: lineColor), ModelVertex(position: coordJ, normal: coordJ, color: lineColor),
            ModelVertex(position: coordH, normal: coordH, color: lineColor), ModelVertex(position: coordL, normal: coordL, color: lineColor),
            ModelVertex(position: coordI, normal: coordI, color: lineColor), ModelVertex(position: coordJ, normal: coordJ, color: lineColor),
            ModelVertex(position: coordI, normal: coordI, color: lineColor), ModelVertex(position: coordK, normal: coordK, color: lineColor),
            ModelVertex(position: coordJ, normal: coordJ, color: lineColor), ModelVertex(position: coordK, normal: coordK, color: lineColor),
            ModelVertex(position: coordJ, normal: coordJ, color: lineColor), ModelVertex(position: coordL, normal: coordL, color: lineColor),
            ModelVertex(position: coordK, normal: coordK, color: lineColor), ModelVertex(position: coordL, normal: coordL, color: lineColor),
        ]

        let points = [
            IcosahedronVertex(name: "A", coordinate: coordA),
            IcosahedronVertex(name: "B", coordinate: coordB),
            IcosahedronVertex(name: "C", coordinate: coordC),
            IcosahedronVertex(name: "D", coordinate: coordD),
            IcosahedronVertex(name: "E", coordinate: coordE),
            IcosahedronVertex(name: "F", coordinate: coordF),
            IcosahedronVertex(name: "G", coordinate: coordG),
            IcosahedronVertex(name: "H", coordinate: coordH),
            IcosahedronVertex(name: "I", coordinate: coordI),
            IcosahedronVertex(name: "J", coordinate: coordJ),
            IcosahedronVertex(name: "K", coordinate: coordK),
            IcosahedronVertex(name: "L", coordinate: coordL),
        ]

        for point in points {
            vertices[point.name] = point
        }

        vertices["C"]!.head      = vertices["I"]
        vertices["C"]!.leftHand  = vertices["D"]
        vertices["C"]!.leftFoot  = vertices["B"]
        vertices["C"]!.rightHand = vertices["E"]
        vertices["C"]!.rightFoot = vertices["A"]

        vertices["B"]!.head      = vertices["A"]
        vertices["B"]!.leftHand  = vertices["C"]
        vertices["B"]!.leftFoot  = vertices["D"]
        vertices["B"]!.rightHand = vertices["H"]
        vertices["B"]!.rightFoot = vertices["F"]

        vertices["A"]!.head      = vertices["E"]
        vertices["A"]!.leftHand  = vertices["C"]
        vertices["A"]!.leftFoot  = vertices["B"]
        vertices["A"]!.rightHand = vertices["F"]
        vertices["A"]!.rightFoot = vertices["G"]

        vertices["E"]!.head      = vertices["G"]
        vertices["E"]!.leftHand  = vertices["K"]
        vertices["E"]!.leftFoot  = vertices["I"]
        vertices["E"]!.rightHand = vertices["C"]
        vertices["E"]!.rightFoot = vertices["A"]

        vertices["G"]!.head      = vertices["L"]
        vertices["G"]!.leftHand  = vertices["K"]
        vertices["G"]!.leftFoot  = vertices["E"]
        vertices["G"]!.rightHand = vertices["A"]
        vertices["G"]!.rightFoot = vertices["F"]

        vertices["L"]!.head      = vertices["F"]
        vertices["L"]!.leftHand  = vertices["H"]
        vertices["L"]!.leftFoot  = vertices["J"]
        vertices["L"]!.rightHand = vertices["K"]
        vertices["L"]!.rightFoot = vertices["G"]

        vertices["F"]!.head      = vertices["H"]
        vertices["F"]!.leftHand  = vertices["L"]
        vertices["F"]!.leftFoot  = vertices["G"]
        vertices["F"]!.rightHand = vertices["A"]
        vertices["F"]!.rightFoot = vertices["B"]

        vertices["H"]!.head      = vertices["J"]
        vertices["H"]!.leftHand  = vertices["L"]
        vertices["H"]!.leftFoot  = vertices["F"]
        vertices["H"]!.rightHand = vertices["B"]
        vertices["H"]!.rightFoot = vertices["D"]

        vertices["J"]!.head      = vertices["K"]
        vertices["J"]!.leftHand  = vertices["L"]
        vertices["J"]!.leftFoot  = vertices["H"]
        vertices["J"]!.rightHand = vertices["D"]
        vertices["J"]!.rightFoot = vertices["I"]

        vertices["K"]!.head      = vertices["I"]
        vertices["K"]!.leftHand  = vertices["E"]
        vertices["K"]!.leftFoot  = vertices["G"]
        vertices["K"]!.rightHand = vertices["L"]
        vertices["K"]!.rightFoot = vertices["J"]

        vertices["I"]!.head      = vertices["D"]
        vertices["I"]!.leftHand  = vertices["C"]
        vertices["I"]!.leftFoot  = vertices["E"]
        vertices["I"]!.rightHand = vertices["K"]
        vertices["I"]!.rightFoot = vertices["J"]

        vertices["D"]!.head      = vertices["C"]
        vertices["D"]!.leftHand  = vertices["I"]
        vertices["D"]!.leftFoot  = vertices["J"]
        vertices["D"]!.rightHand = vertices["H"]
        vertices["D"]!.rightFoot = vertices["B"]
    }

    deinit {
        glDeleteBuffers(1, &pointVertexBuffer)
        glDeleteBuffers(1, &lineVertexBuffer)
        glDeleteVertexArrays(1, &pointVertexArray)
        glDeleteVertexArrays(1, &lineVertexArray)
    }

    func prepare() {
        do {
            let vertexTexturePath = NSBundle.mainBundle().pathForResource("vertex", ofType: "png")!
            vertexTextureInfo = try GLKTextureLoader.textureWithContentsOfFile(vertexTexturePath, options: nil)
        } catch {
            fatalError("Failed to load vertex texture")
        }

        glGenVertexArrays(1, &pointVertexArray)
        glBindVertexArray(pointVertexArray)

        glGenBuffers(1, &pointVertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), pointVertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(ModelVertex.size * pointModelVertices.count), pointVertices, GLenum(GL_STATIC_DRAW))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(0))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(sizeof(Float) * 3))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(sizeof(Float) * 6))

        glGenVertexArrays(1, &lineVertexArray)
        glBindVertexArray(lineVertexArray)
        glGenBuffers(1, &lineVertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), lineVertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(ModelVertex.size * lineModelVertices.count), lineVertices, GLenum(GL_STATIC_DRAW))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(0))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(sizeof(Float) * 3))

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(ModelVertex.size), BUFFER_OFFSET(sizeof(Float) * 6))

        glBindVertexArray(0)
    }

    func render(program: ModelShaderProgram) {
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), vertexTextureInfo.name)

        program.modelMatrix = modelMatrix
        program.vertexTexture = 0

        glLineWidth(8)
        program.useTexture = false
        glBindVertexArray(lineVertexArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), lineVertexBuffer)
        glDrawArrays(GLenum(GL_LINES), 0, GLsizei(lineModelVertices.count))

        program.useTexture = false
        glBindVertexArray(pointVertexArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), pointVertexBuffer)
        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(pointModelVertices.count))
    }
}
