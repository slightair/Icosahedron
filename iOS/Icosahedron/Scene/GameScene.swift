import SpriteKit

class GameScene: SKScene {
    let world: World
    var currentVertexLabelNode: SKLabelNode!

    init(size: CGSize, world: World) {
        self.world = world
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.clearColor()

        setUpCurrentVertexLabel()
    }

    private func setUpCurrentVertexLabel() {
        currentVertexLabelNode = SKLabelNode(fontNamed: "Helvetica")
        currentVertexLabelNode.position = CGPointMake(4, 4)
        currentVertexLabelNode.fontSize = 16
        currentVertexLabelNode.verticalAlignmentMode = .Bottom
        currentVertexLabelNode.horizontalAlignmentMode = .Left
        addChild(currentVertexLabelNode)
    }

    func updateInfo() {
        currentVertexLabelNode.text = "Current: \(world.currentPoint)"
    }
}
