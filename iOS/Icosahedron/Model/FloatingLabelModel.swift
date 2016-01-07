import GLKit

class FloatingLabelModel: LabelModel {
    var animationProgress: Float = 0.0
    var baseSize: Float = 1.0 {
        didSet {
            size = baseSize
        }
    }
    var baseCustomColor: GLKVector4 = GLKVector4Make(0, 0, 0, 0) {
        didSet {
            customColor = baseCustomColor
        }
    }
    var isActive: Bool {
        return animationProgress < 1.0
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        if isActive {
            animationProgress = min(1.0, animationProgress + Float(timeSinceLastUpdate))
        } else {
            animationProgress = 0.0
        }
        self.size = baseSize * animationProgress * 3
        self.customColor = GLKVector4Multiply(self.baseCustomColor, GLKVector4Make(1, 1, 1, 1.0 - animationProgress))
    }
}
