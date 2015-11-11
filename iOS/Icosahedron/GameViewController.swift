import GLKit
import SpriteKit

class GameViewController: GLKViewController {
    @IBOutlet var infoView: SKView!
    var gameScene: GameScene!
    var renderer: Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = EAGLContext(API: .OpenGLES3)
        renderer = Renderer(context: context)

        let glkView = view as! GLKView
        glkView.delegate = renderer
        glkView.context = context
        glkView.drawableColorFormat = .SRGBA8888
        glkView.drawableDepthFormat = .Format24

        gameScene = GameScene(size: view.bounds.size)
        infoView.presentScene(gameScene)
        gameScene.updateInfo(renderer.icosahedronModel.currentVertex)
    }

    func update() {
        renderer.update(timeSinceLastUpdate)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        var location = touch.locationInView(view)
        location.x -= CGRectGetMidX(view.bounds)
        location.y -= CGRectGetMidY(view.bounds)
        let normalizedLocation = CGPointMake(location.x * 2 / CGRectGetWidth(view.bounds),
                                            -location.y * 2 / CGRectGetHeight(view.bounds))

        renderer.icosahedronModel.rotateModelWithTappedLocation(normalizedLocation)
        gameScene.updateInfo(renderer.icosahedronModel.currentVertex)
    }
}
