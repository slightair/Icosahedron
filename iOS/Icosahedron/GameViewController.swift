import GLKit
import SpriteKit

class GameViewController: GLKViewController, GameSceneRendererDelegate {
    static let detectActionThreshold: Float = 160

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

        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.addTarget(self, action: "panAction:")
        gestureRecognizer.maximumNumberOfTouches = 1

        glkView.addGestureRecognizer(gestureRecognizer)
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
                renderer.rotateModelWithTappedLocation(CGPoint(x: -velocity.x, y: velocity.y))
            }
        default:
            break
        }
    }
}
