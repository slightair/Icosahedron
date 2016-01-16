import GLKit

class ParticleEmitter {
    static let ParticleCountMax = 10000
//    var duration: Float = 0.05
    var lifeTime = 1.0
    var emissionInterval = 0.01
    var speed = 0.05
    var position = GLKVector3Make(0, 0, 0)
    var color = GLKVector4Make(1, 1, 1, 1)
    let particles: [Particle]
    var time: NSTimeInterval = 0
    var nextParticleIndex = 0 {
        didSet {
            if nextParticleIndex >= ParticleEmitter.ParticleCountMax {
                nextParticleIndex = 0
            }
        }
    }

    var activeParticle: [Particle] {
        return particles.filter { $0.isActive }
    }

    init() {
        particles = (0..<ParticleEmitter.ParticleCountMax).map { _ in
            return Particle()
        }
    }

    func update(timeSinceLastUpdate: NSTimeInterval) {
        time += timeSinceLastUpdate

        var newParticles: [Particle] = []
        while time > emissionInterval {
            for particle in newParticles {
                particle.time += emissionInterval
            }

            let nextParticle = particles[nextParticleIndex]
            nextParticle.lifeTime = lifeTime
            nextParticle.speed = speed
            nextParticle.basePosition = position
            nextParticle.baseColor = color
            nextParticle.start()

            newParticles.append(nextParticle)

            nextParticleIndex++
            time -= emissionInterval
        }

        for particle in activeParticle {
            particle.update(timeSinceLastUpdate)
        }
    }
}
