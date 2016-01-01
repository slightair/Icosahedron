import GLKit
import SpriteKit

class GameViewController: GLKViewController, RendererDelegate {
    var renderer: Renderer!
    let world = World()

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = EAGLContext(API: .OpenGLES3)
        renderer = Renderer(context: context, world: world)
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
        let normalizedLocation = CGPointMake(location.x * 2 / CGRectGetWidth(view.bounds),
                                            -location.y * 2 / CGRectGetHeight(view.bounds))

        renderer.rotateModelWithTappedLocation(normalizedLocation)
    }

    func didChangeIcosahedronPoint(point: Icosahedron.Point) {
        world.currentPoint = point
    }
}
