import GLKit
import OpenGLES

func quaternionForRotate(from from: GLKVector3, to: GLKVector3) -> GLKQuaternion {
    let normalizedFrom = GLKVector3Normalize(from)
    let normalizedTo = GLKVector3Normalize(to)

    let cosineTheta = GLKVector3DotProduct(normalizedFrom, normalizedTo)
    let rotationAxis = GLKVector3CrossProduct(normalizedFrom, normalizedTo)

    let s = sqrtf((1 + cosineTheta) * 2)
    let inverse = 1 / s

    return GLKQuaternionMakeWithVector3(GLKVector3MultiplyScalar(rotationAxis, inverse), s * 0.5)
}

class Renderer: NSObject, GLKViewDelegate {
    let context: EAGLContext

    var modelShaderProgram: ModelShaderProgram!

    let icosahedronModel = IcosahedronModel()
    var markerModel = TetrahedronModel()

    var projectionMatrix = GLKMatrix4Identity
    var worldMatrix = GLKMatrix4Identity
    var normalMatrix = GLKMatrix3Identity

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
        markerModel.position = currentVertex.coordinate
        markerModel.quaternion = quaternionForRotate(from: markerModel.topCoordinate, to: markerModel.position)

        setUpGL()

        models.append(icosahedronModel)
        models.append(markerModel)

        update(0)
    }

    func setUpGL() {
        EAGLContext.setCurrentContext(context)

        modelShaderProgram = ModelShaderProgram()

        icosahedronModel.prepare()
        markerModel.prepare()

        let width = GLsizei(CGRectGetHeight(UIScreen.mainScreen().nativeBounds)) // long side
        let height = GLsizei(CGRectGetWidth(UIScreen.mainScreen().nativeBounds)) // short side

        let aspect = Float(fabs(Double(width) / Double(height)))
        let projectionWidth: Float = 1.0
        let projectionHeight = projectionWidth / aspect
        projectionMatrix = GLKMatrix4MakeOrtho(-projectionWidth / 2, projectionWidth / 2, -projectionHeight / 2, projectionHeight / 2, 0.1, 100)
    }

    func tearDownGL() {

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

        let relativeQuaternion = quaternionForRotate(from: currentVertex.coordinate, to: prevVertex.coordinate)

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
        glEnable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE))

        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))

        glUseProgram(modelShaderProgram.programID)

        modelShaderProgram.projectionMatrix = projectionMatrix
        modelShaderProgram.worldMatrix = worldMatrix
        modelShaderProgram.normalMatrix = normalMatrix

        for model in models {
            model.render(modelShaderProgram)
        }

        glBindVertexArray(0)
    }
}
