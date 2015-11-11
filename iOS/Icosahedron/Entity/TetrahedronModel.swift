import GLKit

struct TetrahedronModel {
    static let NumberOfFaceVertices: GLsizei = 6

    var faceModelVertices: [ModelVertex]

    func createFaceNormal(x: GLKVector3, y: GLKVector3, z: GLKVector3) -> GLKVector3 {
        return GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(x, y), GLKVector3Subtract(y, z)))
    }

    func faceVertices() -> [Float] {
        return faceModelVertices.flatMap { $0.v }
    }

    init() {
        let scale: Float = 0.05

        let coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1, 1, 1), scale)
        let coordB = GLKVector3MultiplyScalar(GLKVector3Make( 1,-1,-1), scale)
        let coordC = GLKVector3MultiplyScalar(GLKVector3Make(-1, 1,-1), scale)
        let coordD = GLKVector3MultiplyScalar(GLKVector3Make(-1,-1, 1), scale)

        let pointColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)

        faceModelVertices = [
            ModelVertex(position: coordD, normal: coordD, color: pointColor),
            ModelVertex(position: coordB, normal: coordB, color: pointColor),
            ModelVertex(position: coordC, normal: coordC, color: pointColor),
            ModelVertex(position: coordA, normal: coordA, color: pointColor),
            ModelVertex(position: coordD, normal: coordD, color: pointColor),
            ModelVertex(position: coordB, normal: coordB, color: pointColor),
        ]
    }
}
