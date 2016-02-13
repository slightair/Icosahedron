import GLKit

class GameViewController: GLKViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let context = EAGLContext(API: .OpenGLES2)
        EAGLContext.setCurrentContext(context)

        let glkView = view as! GLKView
        glkView.context = context
        glkView.drawableColorFormat = .SRGBA8888
        glkView.drawableDepthFormat = .Format24

        TextureSet.sharedSet.loadTextures()
        FontData.defaultData.loadTexture()

        let sceneSwitcher = SceneSwitcher.sharedSwitcher
        sceneSwitcher.contextView = glkView
        sceneSwitcher.switchScene(.Game)
        sceneSwitcher.sceneLock = true
    }

    func update() {
        SceneSwitcher.sharedSwitcher.currentScene?.update(timeSinceLastUpdate)
    }
}
