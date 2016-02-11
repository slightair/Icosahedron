import GLKit

class TitleScene: NSObject, SceneType {
    let glkView: GLKView
    var renderer: TitleSceneRenderer

    required init(view: GLKView) {
        self.glkView = view
        self.renderer = TitleSceneRenderer()

        super.init()
    }

    func setUp() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: "tapAction:")

        glkView.addGestureRecognizer(tapGestureRecognizer)
    }

    func tearDown() {
        if let registeredGestureRecognizers = glkView.gestureRecognizers {
            for gestureRecognizer in registeredGestureRecognizers {
                glkView.removeGestureRecognizer(gestureRecognizer)
            }
        }
    }

    func update(timeSinceLastUpdate: NSTimeInterval = 0) {
        renderer.update(timeSinceLastUpdate)
    }

    func tapAction(gestureRecognizer: UITapGestureRecognizer) {
        SceneSwitcher.sharedSwitcher.switchScene(.Game)
    }

    // MARK: - GLKView delegate methods

    func glkView(view: GLKView, drawInRect rect: CGRect) {
        renderer.render()
    }
}
