import GLKit

class TitleSceneRenderer: BaseRenderer {
    var backgroundShaderProgram: BackgroundShaderProgram!
    var uiShaderProgram: UIShaderProgram!
    let modelProducer = TitleSceneModelProducer()

    override func setUp() {
        super.setUp()

        backgroundShaderProgram = BackgroundShaderProgram()
        uiShaderProgram = UIShaderProgram()
        update()
    }

    private func renderBackground() {
        glEnable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(backgroundShaderProgram.programID)
        backgroundShaderProgram.projectionMatrix = backgroundProjectionMatrix
        backgroundShaderProgram.worldMatrix = backgroundWorldMatrix
        backgroundShaderProgram.normalMatrix = backgroundNormalMatrix

        let meshTextureInfo = TextureSet.sharedSet[.Mesh]
        glBindTexture(GLenum(GL_TEXTURE_2D), meshTextureInfo.name)
        drawModels(modelProducer.backgroundModelObjects())
    }

    private func renderUI() {
        glDisable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(uiShaderProgram.programID)
        uiShaderProgram.projectionMatrix = modelProjectionMatrix

        glBindTexture(GLenum(GL_TEXTURE_2D), FontData.defaultData.textureInfo.name)
        drawModels(modelProducer.uiLabelObjects())
    }

    func render() {
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))

        glEnable(GLenum(GL_BLEND))
        glActiveTexture(GLenum(GL_TEXTURE0))

        renderBackground()
        renderUI()
    }

    func update(timeSinceLastUpdate: NSTimeInterval = 0) {
        modelProducer.update(timeSinceLastUpdate)

        let baseQuaternion = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(150), 1.0, 0.0, 0.0)
        let axis = GLKVector3Normalize(GLKVector3Make(1, 0, 0))
        let worldQuaternion = GLKQuaternionMultiply(baseQuaternion, GLKQuaternionMakeWithAngleAndVector3Axis(Float(2 * M_PI * modelProducer.animationLoopValue), axis))

        let baseMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -1.0)
        worldMatrix = GLKMatrix4Multiply(baseMatrix, GLKMatrix4MakeWithQuaternion(worldQuaternion))
        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(worldMatrix), nil)

        let backgroundBaseMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -2.0)
        backgroundWorldMatrix = GLKMatrix4Multiply(backgroundBaseMatrix, GLKMatrix4MakeWithQuaternion(worldQuaternion))
        backgroundNormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(backgroundWorldMatrix), nil)
    }
}
