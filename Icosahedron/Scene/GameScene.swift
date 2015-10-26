import SpriteKit

class GameScene: SKScene {
    let circleNode = SKNode()
    var currentVertexLabelNode: SKLabelNode!
    var vertexLabels: [SKLabelNode] = []
    var radius: CGFloat {
        return self.size.height / 2 * 0.9
    }
    let unit: CGFloat = CGFloat(2 * M_PI) / 5
    var updateCount = 0

    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.clearColor()

        setUpCurrentVertexLabel()
        setUpVertexLabels()
    }

    private func setUpCurrentVertexLabel() {
        self.currentVertexLabelNode = SKLabelNode(fontNamed: "Helvetica")
        self.currentVertexLabelNode.position = CGPointMake(4, 4)
        self.currentVertexLabelNode.fontSize = 16
        self.currentVertexLabelNode.verticalAlignmentMode = .Bottom
        self.currentVertexLabelNode.horizontalAlignmentMode = .Left
        self.addChild(self.currentVertexLabelNode)
    }

    private func setUpVertexLabels() {
        self.circleNode.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        self.addChild(self.circleNode)

        for var i = 0; i < 5; i++ {
            let theta = self.unit * CGFloat(i) + self.unit / 2
            let arcPath = UIBezierPath(arcCenter: CGPointZero,
                radius: self.radius,
                startAngle: theta,
                endAngle: theta + self.unit,
                clockwise: true)
            let arcNode = SKShapeNode(path: arcPath.CGPath)
            arcNode.strokeColor = UIColor(hue: (theta / CGFloat(2 * M_PI)), saturation: 0.5, brightness: 1.0, alpha: 0.75)
            arcNode.lineWidth = 24
            self.circleNode.addChild(arcNode)

            let vertexLabel = SKLabelNode(fontNamed: "Helvetica")
            vertexLabel.horizontalAlignmentMode = .Center
            vertexLabel.verticalAlignmentMode = .Center
            vertexLabels.append(vertexLabel)

            self.addChild(vertexLabel)
        }

        self.circleNode.runAction(SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 0))
    }

    func updateInfo(currentVertex: IcosahedronVertex) {
        self.currentVertexLabelNode.text = "Current: \(currentVertex)"
        self.circleNode.runAction(SKAction.rotateByAngle(CGFloat(M_PI) / 5, duration: 0))

        for (i, label) in self.vertexLabels.enumerate() {
            let theta = self.unit * CGFloat(i) + CGFloat(M_PI_2) + self.unit / 2 + CGFloat(self.updateCount) * (CGFloat(M_PI) / 5)
            label.text = currentVertex.nextVertexNames[i]
            label.position = CGPointMake(
                self.size.width / 2 + self.radius * cos(theta),
                self.size.height / 2 + self.radius * sin(theta)
            )
        }
        self.updateCount++
    }
}
