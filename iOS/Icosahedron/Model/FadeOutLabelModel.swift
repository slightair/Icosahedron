import GLKit

class FadeOutLabelModel: LabelModel {
    var animationProgress: Float = 1.0
    var duration: Float = 0.5
    var baseTextColor: GLKVector4 = GLKVector4Make(0, 0, 0, 0) {
        didSet {
            textColor = baseTextColor
        }
    }
    var baseBackgroundColor = LabelModel.defaultBackgroundColor {
        didSet {
            backgroundColor = baseBackgroundColor
        }
    }
    var isActive: Bool {
        return animationProgress < 1.0
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        if isActive {
            animationProgress = min(1.0, animationProgress + Float(timeSinceLastUpdate) * (1 / duration))

            let alpha: Float
            if animationProgress < 0.75 {
                alpha = 1.0
            } else {
                alpha = 1.0 - (animationProgress - 0.75) * 4
            }
            textColor = GLKVector4Multiply(baseTextColor, GLKVector4Make(1, 1, 1, alpha))
            backgroundColor = GLKVector4Multiply(baseBackgroundColor, GLKVector4Make(1, 1, 1, alpha))
            updateLocalModelVertices()
        }
    }
}
