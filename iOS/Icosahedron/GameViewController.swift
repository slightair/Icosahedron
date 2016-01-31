import GLKit
import SpriteKit

class GameViewController: GLKViewController, GameSceneRendererDelegate {
    static let detectActionThreshold: Float = 200

    var renderer: GameSceneRenderer!
    let world = World()

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = EAGLContext(API: .OpenGLES2)
        renderer = GameSceneRenderer(context: context, world: world)
        renderer.delegate = self

        let glkView = view as! GLKView
        glkView.delegate = renderer
        glkView.context = context
        glkView.drawableColorFormat = .SRGBA8888
        glkView.drawableDepthFormat = .Format24

        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: "panAction:")
        panGestureRecognizer.maximumNumberOfTouches = 1

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: "tapAction:")

        glkView.addGestureRecognizer(panGestureRecognizer)
        glkView.addGestureRecognizer(tapGestureRecognizer)
    }

    func update() {
        world.update(timeSinceLastUpdate)
        renderer.update(timeSinceLastUpdate)
    }

    func didChangeIcosahedronPoint(point: Icosahedron.Point) {
        world.currentPoint.value = point
    }

    func panAction(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Changed:
            let velocity = gestureRecognizer.velocityInView(view)
            if GLKVector2Length(GLKVector2Make(Float(velocity.x), Float(velocity.y))) > GameViewController.detectActionThreshold {
                renderer.rotateModelWithTappedLocation(CGPoint(x: velocity.x, y: -velocity.y))
            }
        default:
            break
        }
    }

    func tapAction(gestureRecognizer: UITapGestureRecognizer) {
        var location = gestureRecognizer.locationInView(view)
        location.x -= CGRectGetMidX(view.bounds)
        location.y -= CGRectGetMidY(view.bounds)
        let normalizedLocation = CGPoint(x: location.x * 2 / CGRectGetWidth(view.bounds),
            y: -location.y * 2 / CGRectGetHeight(view.bounds))

        renderer.rotateModelWithTappedLocation(normalizedLocation)
    }
}
