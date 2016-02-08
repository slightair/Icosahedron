import GLKit

class GameScene: NSObject, SceneType, GameSceneRendererDelegate {
    static let detectActionThreshold: Float = 200

    let glkView: GLKView
    var renderer: GameSceneRenderer!
    let world = World()

    required init(view: GLKView) {
        self.glkView = view

        super.init()

        renderer = GameSceneRenderer(world: world)
        renderer.delegate = self
    }

    func setUp() {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: "panAction:")
        panGestureRecognizer.maximumNumberOfTouches = 1

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: "tapAction:")

        glkView.addGestureRecognizer(panGestureRecognizer)
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
        world.update(timeSinceLastUpdate)
        renderer.update(timeSinceLastUpdate)
    }

    func panAction(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Changed:
            let velocity = gestureRecognizer.velocityInView(glkView)
            if GLKVector2Length(GLKVector2Make(Float(velocity.x), Float(velocity.y))) > GameScene.detectActionThreshold {
                renderer.rotateModelWithTappedLocation(CGPoint(x: velocity.x, y: -velocity.y))
            }
        default:
            break
        }
    }

    func tapAction(gestureRecognizer: UITapGestureRecognizer) {
        var location = gestureRecognizer.locationInView(glkView)
        location.x -= CGRectGetMidX(glkView.bounds)
        location.y -= CGRectGetMidY(glkView.bounds)
        let normalizedLocation = CGPoint(x: location.x * 2 / CGRectGetWidth(glkView.bounds),
            y: -location.y * 2 / CGRectGetHeight(glkView.bounds))

        renderer.rotateModelWithTappedLocation(normalizedLocation)
    }

    // MARK: - GLKView delegate methods

    func glkView(view: GLKView, drawInRect rect: CGRect) {
        renderer.render()
    }

    // MARK: - GameSceneRendererDelegate

    func didChangeIcosahedronPoint(point: Icosahedron.Point) {
        world.currentPoint.value = point
    }
}
