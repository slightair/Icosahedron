import GLKit

class TitleSceneRenderer: BaseRenderer {
    var uiShaderProgram: UIShaderProgram!

    var titleLabel = LabelModel(text: "Icosahedron")

    override func setUp() {
        super.setUp()

        uiShaderProgram = UIShaderProgram()
    }

    private func renderUI() {
        glDisable(GLenum(GL_DEPTH_TEST))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glUseProgram(uiShaderProgram.programID)
        uiShaderProgram.projectionMatrix = modelProjectionMatrix

        glBindTexture(GLenum(GL_TEXTURE_2D), FontData.defaultData.textureInfo.name)
        drawModels([titleLabel])
    }

    func render() {
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))

        glEnable(GLenum(GL_BLEND))
        glActiveTexture(GLenum(GL_TEXTURE0))

        renderUI()
    }

    func update(timeSinceLastUpdate: NSTimeInterval = 0) {

    }
}
