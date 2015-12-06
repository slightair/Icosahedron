import GLKit

struct ModelVertex {
    static let size = sizeof(Float) * 12

    let position: GLKVector3
    let normal: GLKVector3
    let color: GLKVector4
    let texCoord: GLKVector2

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
            texCoord.s,
            texCoord.t,
        ]
    }

    func multiplyMatrix4(matrix: GLKMatrix4) -> ModelVertex {
        return ModelVertex(position: GLKMatrix4MultiplyVector3(matrix, position), normal: GLKMatrix4MultiplyVector3(matrix, normal), color: color, texCoord: texCoord)
    }

    func addVector3(vector: GLKVector3) -> ModelVertex {
        return ModelVertex(position: GLKVector3Add(position, vector), normal: GLKVector3Add(normal, vector), color: color, texCoord: texCoord)
    }

    func changeColor(color: GLKVector4) -> ModelVertex {
        return ModelVertex(position: position, normal: normal, color: color, texCoord: texCoord)
    }
}
