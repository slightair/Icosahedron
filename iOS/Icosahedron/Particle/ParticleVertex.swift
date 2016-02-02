import GLKit

struct ParticleVertex {
    static let size = sizeof(Float) * 8

    var position: GLKVector3
    var color: GLKVector4
    var pointSize: Float

    var v: [Float] {
        return [
            position.x,
            position.y,
            position.z,
            color.r,
            color.g,
            color.b,
            color.a,
            pointSize,
        ]
    }
}
