import GLKit

class SceneSwitcher {
    static let sharedSwitcher = SceneSwitcher()

    var contextView: GLKView!
    var currentScene: SceneType?

    func switchScene(scene: Scene) {
        let sceneType = Scene.createScene(scene, view: contextView)

        currentScene?.tearDown()
        contextView.delegate = sceneType
        currentScene = sceneType
        sceneType.setUp()
    }
}
