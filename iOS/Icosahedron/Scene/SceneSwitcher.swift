import GLKit

class SceneSwitcher {
    static let sharedSwitcher = SceneSwitcher()

    var contextView: GLKView!
    var currentScene: SceneType?
    var sceneLock: Bool = false

    func switchScene(scene: Scene) {
        if sceneLock {
            return
        }

        let sceneType = Scene.createScene(scene, view: contextView)

        currentScene?.tearDown()
        contextView.delegate = sceneType
        currentScene = sceneType
        sceneType.setUp()
    }
}
