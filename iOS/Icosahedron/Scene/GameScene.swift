import GLKit

class GameScene: NSObject, SceneType {
    static let detectActionThreshold: Float = 200

    let glkView: GLKView
    var renderer: GameSceneRenderer!
    let world = World()
    var movingProgress = 0.0 {
        didSet {
            renderer.movingProgress = Float(movingProgress)
            if movingProgress == 1.0 {
                world.currentPoint.value = renderer.currentVertex.point
            }
        }
    }

    required init(view: GLKView) {
        self.glkView = view

        super.init()

        renderer = GameSceneRenderer(world: world)
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
        if movingProgress < 1.0 {
            movingProgress = min(1.0, movingProgress + timeSinceLastUpdate * 4)
        }
        world.update(timeSinceLastUpdate)
        renderer.update(timeSinceLastUpdate)
    }

    func panAction(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Changed:
            let velocity = gestureRecognizer.velocityInView(glkView)
            if GLKVector2Length(GLKVector2Make(Float(velocity.x), Float(velocity.y))) > GameScene.detectActionThreshold {
                rotateModelWithTappedLocation(CGPoint(x: velocity.x, y: -velocity.y))
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
        rotateModelWithTappedLocation(normalizedLocation)
    }

    func rotateModelWithTappedLocation(location: CGPoint) {
        if movingProgress < 1.0 {
            return
        }
        movingProgress = 0.0
        renderer.rotateModelWithTappedLocation(location)
    }

    // MARK: - GLKView delegate methods

    func glkView(view: GLKView, drawInRect rect: CGRect) {
        renderer.render()
    }
}
