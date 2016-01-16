import GLKit

struct ParticleVertex {
    static let size = sizeof(Float) * 7

    var position: GLKVector3
    var color: GLKVector4

    var v: [Float] {
        return [
            position.x,
            position.y,
            position.z,
            color.r,
            color.g,
            color.b,
            color.a,
        ]
    }
}
