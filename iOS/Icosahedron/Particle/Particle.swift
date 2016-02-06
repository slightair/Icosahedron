import GLKit

class Particle {
    var vertex: ParticleVertex = ParticleVertex(position: GLKVector3Make(0, 0, 0), color: GLKVector4Make(1, 1, 1, 1), pointSize: 0)
    var time = 0.0
    var lifeTime = 0.0
    var speed = 0.0
    var direction = GLKVector3Make(0, 0, 0)
    var basePosition = GLKVector3Make(0, 0, 0)
    var baseColor = GLKVector4Make(0, 0, 0, 0)
    var basePointSize: Float = 48
    var isActive: Bool {
        return lifeTime > time
    }
    var changeSize = false
    var changeAlpha = false
    var isPermanent = false

    func start() {
        time = isPermanent ? -1.0 : 0.0

        vertex.position = basePosition
        vertex.color = baseColor
        vertex.pointSize = basePointSize
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        if isPermanent {
            return
        }

        time += timeSinceLastUpdate
        vertex.position = GLKVector3Add(basePosition, GLKVector3MultiplyScalar(direction, Float(time * speed)))
        if changeAlpha {
            vertex.color = GLKVector4Subtract(baseColor, GLKVector4Make(0, 0, 0, Float(time / lifeTime)))
        }
        if changeSize {
            vertex.pointSize = max(0, basePointSize * Float(1 - time / lifeTime))
        }
    }
}
