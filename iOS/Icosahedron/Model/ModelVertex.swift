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

    func multiplyMatrix4(matrix: GLKMatrix4) -> ModelVertex {
        return ModelVertex(position: GLKMatrix4MultiplyVector3(matrix, position), normal: GLKMatrix4MultiplyVector3(matrix, normal), color: color)
    }

    func addVector3(vector: GLKVector3) -> ModelVertex {
        return ModelVertex(position: GLKVector3Add(position, vector), normal: GLKVector3Add(normal, vector), color: color)
    }
}
