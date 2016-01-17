import GLKit

class SequenceLabelModelGroup {
    enum Direction {
        case Up, Down
    }

    var activeLabels: [FadeOutLabelModel] = []

    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var size: Float = 0.2
    var horizontalAlign: RenderableHorizontalAlign = .Center
    var verticalAlign: RenderableVerticalAlign = .Center
    var duration: Float = 0.5
    var direction: Direction = .Down
    var showBackground = false
    var baseBackgroundColor = LabelModel.defaultBackgroundColor

    func appendNewLabel(text: String, color: GLKVector4) {
        let newLabel = FadeOutLabelModel(text: text)
        newLabel.position = position
        newLabel.size = size
        newLabel.horizontalAlign = horizontalAlign
        newLabel.verticalAlign = verticalAlign
        newLabel.baseTextColor = color
        newLabel.duration = duration
        newLabel.animationProgress = 0.0
        newLabel.showBackground = showBackground
        newLabel.baseBackgroundColor = baseBackgroundColor

        for label in activeLabels {
            let labelHeight = newLabel.glyphHeight + newLabel.backgroundMarginVertical * 2
            let addY = direction == .Down ? labelHeight : -labelHeight
            label.position = GLKVector3Add(label.position, GLKVector3Make(0, addY, 0))
        }
        activeLabels.append(newLabel)
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        for label in activeLabels {
            label.update(timeSinceLastUpdate)
        }
        activeLabels = activeLabels.filter { $0.isActive }
    }
}
