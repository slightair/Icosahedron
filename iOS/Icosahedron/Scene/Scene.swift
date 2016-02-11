import GLKit

enum Scene {
    case Title, Game

    static func createScene(scene: Scene, view: GLKView) -> SceneType {
        switch scene {
        case .Title:
            return TitleScene(view: view)
        case .Game:
            return GameScene(view: view)
        }
    }
}

protocol SceneType: GLKViewDelegate {
    var glkView: GLKView { get }

    init(view: GLKView)

    func setUp()
    func tearDown()
    func update(timeSinceLastUpdate: NSTimeInterval)
}
