import GLKit

struct ModelVertex {
    static let size = sizeof(Float) * 10

    let position: GLKVector3
    let normal: GLKVector3
    let color: GLKVector4

    var v: [Float] {
        return [
            position.x,
            position.y,
            position.z,
            normal.x,
            normal.y,
            normal.z,
            color.r,
            color.g,
            color.b,
            color.a,
        ]
    }
}
