import GLKit
import SpriteKit

class GameViewController: GLKViewController, GameSceneRendererDelegate {
    var renderer: GameSceneRenderer!
    let world = World()

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = EAGLContext(API: .OpenGLES3)
        renderer = GameSceneRenderer(context: context, world: world)
        renderer.delegate = self

        let glkView = view as! GLKView
        glkView.delegate = renderer
        glkView.context = context
        glkView.drawableColorFormat = .SRGBA8888
        glkView.drawableDepthFormat = .Format24
    }

    func update() {
        world.update(timeSinceLastUpdate)
        renderer.update(timeSinceLastUpdate)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        var location = touch.locationInView(view)
        location.x -= CGRectGetMidX(view.bounds)
        location.y -= CGRectGetMidY(view.bounds)
        let normalizedLocation = CGPoint(x: location.x * 2 / CGRectGetWidth(view.bounds),
                                         y: -location.y * 2 / CGRectGetHeight(view.bounds))

        renderer.rotateModelWithTappedLocation(normalizedLocation)
    }

    func didChangeIcosahedronPoint(point: Icosahedron.Point) {
        world.currentPoint.value = point
    }
}
