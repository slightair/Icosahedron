import GLKit
import Chameleon

class TitleSceneModelProducer {
    let sphereModel = SphereModel()
    let titleLabel = LabelModel(text: "Icosahedron")

    var animationLoopValue = 0.0

    init() {
        titleLabel.size = 0.5
        titleLabel.textColor = UIColor.flatGrayColorDark().glColor
        titleLabel.updateLocalModelVertices()
    }

    func backgroundModelObjects() -> [Renderable] {
        return [sphereModel]
    }

    func modelObjects() -> [Renderable] {
        return []
    }

    func labelObjects() -> [LabelModel] {
        return []
    }

    func uiObjects() -> [Renderable] {
        return []
    }

    func uiLabelObjects() -> [Renderable] {
        return [titleLabel]
    }

    func particlePoints() -> [ParticleVertex] {
        return []
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        animationLoopValue += timeSinceLastUpdate
        if animationLoopValue > 1.0 {
            animationLoopValue -= 1.0
        }

    }
}
