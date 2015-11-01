import SpriteKit

class GameScene: SKScene {
    var currentVertexLabelNode: SKLabelNode!

    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.clearColor()

        setUpCurrentVertexLabel()
    }

    private func setUpCurrentVertexLabel() {
        self.currentVertexLabelNode = SKLabelNode(fontNamed: "Helvetica")
        self.currentVertexLabelNode.position = CGPointMake(4, 4)
        self.currentVertexLabelNode.fontSize = 16
        self.currentVertexLabelNode.verticalAlignmentMode = .Bottom
        self.currentVertexLabelNode.horizontalAlignmentMode = .Left
        self.addChild(self.currentVertexLabelNode)
    }

    func updateInfo(currentVertex: IcosahedronVertex) {
        self.currentVertexLabelNode.text = "Current: \(currentVertex)"
    }
}
