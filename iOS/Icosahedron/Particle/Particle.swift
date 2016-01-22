import GLKit

class Particle {
    var vertex: ParticleVertex = ParticleVertex(position: GLKVector3Make(0, 0, 0), color: GLKVector4Make(1, 1, 1, 1))
    var time = 0.0
    var lifeTime = 0.0
    var speed = 0.0
    var direction = GLKVector3Make(0, 0, 0)
    var basePosition = GLKVector3Make(0, 0, 0)
    var baseColor = GLKVector4Make(0, 0, 0, 0)
    var isActive: Bool {
        return lifeTime > time
    }

    func start() {
        func randomValue() -> Float {
            return Float(arc4random()) / Float(UINT32_MAX) * 2 - 1
        }

        time = 0.0
        direction = GLKVector3Normalize(GLKVector3Make(randomValue(), randomValue(), randomValue()))
        vertex.position = basePosition
        vertex.color = baseColor
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        time += timeSinceLastUpdate
        vertex.position = GLKVector3Add(basePosition, GLKVector3MultiplyScalar(direction, Float(time * speed)))
        vertex.color = GLKVector4Subtract(baseColor, GLKVector4Make(0, 0, 0, Float(time / lifeTime)))
    }
}