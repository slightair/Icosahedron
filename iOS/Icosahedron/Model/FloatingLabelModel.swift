import GLKit

class FloatingLabelModel: LabelModel {
    var animationProgress: Float = 1.0
    var duration: Float = 0.5
    var baseSize: Float = 1.0 {
        didSet {
            size = baseSize
        }
    }
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

            size = baseSize * animationProgress * 5
            textColor = GLKVector4Multiply(baseTextColor, GLKVector4Make(1, 1, 1, 1.0 - animationProgress))
            backgroundColor = GLKVector4Multiply(baseBackgroundColor, GLKVector4Make(1, 1, 1, 1.0 - animationProgress))
            updateLocalModelVertices()
        }
    }
}
