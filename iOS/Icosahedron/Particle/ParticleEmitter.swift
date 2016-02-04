import GLKit

class ParticleEmitter {
    static let ParticleCountMax = 1000
    var duration = 0.2 {
        didSet {
            progress = duration
        }
    }
    var lifeTime = 1.0
    var emissionInterval = 0.05
    var speed = 0.03
    var position = GLKVector3Make(0, 0, 0)
    var color = GLKVector4Make(1, 1, 1, 1)

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

    var activeParticle: [Particle] {
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
        func randomValue() -> Float {
            return Float(arc4random()) / Float(UINT32_MAX) * 2 - 1
        }

        particle.lifeTime = lifeTime
        particle.speed = speed
        particle.basePosition = position
        particle.baseColor = color
        particle.direction = GLKVector3Normalize(GLKVector3Make(randomValue(), randomValue(), randomValue()))
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

        for particle in activeParticle {
            particle.update(timeSinceLastUpdate)
        }
    }
}
