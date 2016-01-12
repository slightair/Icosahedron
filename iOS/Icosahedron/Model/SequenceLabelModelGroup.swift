import GLKit

class SequenceLabelModelGroup {
    var activeLabels: [FadeOutLabelModel] = []

    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var size: Float = 0.2
    var horizontalAlign: RenderableHorizontalAlign = .Center
    var verticalAlign: RenderableVerticalAlign = .Center
    var baseCustomColor: GLKVector4 = GLKVector4Make(0, 0, 0, 0)
    var duration: Float = 0.5

    func appendNewLabel(text: String) {
        let newLabel = FadeOutLabelModel(text: text)
        newLabel.position = position
        newLabel.size = size
        newLabel.horizontalAlign = horizontalAlign
        newLabel.verticalAlign = verticalAlign
        newLabel.baseCustomColor = baseCustomColor
        newLabel.duration = duration
        newLabel.animationProgress = 0.0

        for label in activeLabels {
            label.position = GLKVector3Add(label.position, GLKVector3Make(0, newLabel.glyphHeight, 0))
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
