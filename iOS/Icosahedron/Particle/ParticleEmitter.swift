import GLKit

class ParticleEmitter {
    static let ParticleCountMax = 1000
    var duration = 0.2 {
        didSet {
            progress = duration
        }
    }
    var emissionInterval = 0.05
    var lifeTimeFunction: (Void -> Double) = { 1.0 }
    var speedFunction: (Void -> Double) = { 0.03 }
    var directionFunction: (Void -> GLKVector3) = {
        func randomValue() -> Float {
            return Float(drand48() * 2 - 1)
        }
        return GLKVector3Normalize(GLKVector3Make(randomValue(), randomValue(), randomValue()))
    }
    var positionFunction: (Void -> GLKVector3) = { GLKVector3Make(0, 0, 0) }
    var colorFunction: (Void -> GLKVector4) = { GLKVector4Make(1, 1, 1, 1) }
    var pointSizeFunction: (Void -> Float) = { 48 }
    var changeSize = false

    let particles: [Particle]
    var emissionClock: NSTimeInterval = 0
    var progress = 0.0
    var nextParticleIndex = 0 {
        didSet {
            if nextParticleIndex >= ParticleEmitter.ParticleCountMax {
                nextParticleIndex = 0
            }
        }
    }

    var active: Bool {
        return progress < duration
    }

    var activeParticles: [Particle] {
        return particles.filter { $0.isActive }
    }

    init() {
        particles = (0..<self.dynamicType.ParticleCountMax).map { _ in
            return Particle()
        }
        progress = duration
    }

    func emit() {
        progress = 0.0
        emissionClock = 0.0
    }

    func setUpNewParticle(particle: Particle) {
        particle.lifeTime = lifeTimeFunction()
        particle.speed = speedFunction()
        particle.basePosition = positionFunction()
        particle.baseColor = colorFunction()
        particle.basePointSize = pointSizeFunction()
        particle.changeSize = changeSize
        particle.direction = directionFunction()
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        if active {
            progress += timeSinceLastUpdate
            emissionClock += timeSinceLastUpdate

            var newParticles: [Particle] = []
            while emissionClock > emissionInterval {
                for particle in newParticles {
                    particle.time += emissionInterval
                }

                let nextParticle = particles[nextParticleIndex]
                setUpNewParticle(nextParticle)
                nextParticle.start()
                newParticles.append(nextParticle)

                nextParticleIndex++
                emissionClock -= emissionInterval
            }
        }

        for particle in activeParticles {
            particle.update(timeSinceLastUpdate)
        }
    }
}
