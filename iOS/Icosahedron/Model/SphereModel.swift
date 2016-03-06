import GLKit

class SphereModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    let scale: GLKVector3 = GLKVector3Make(1.0, 1.0, 1.0)
    let r: Float = 3

    init() {
        let split = 24
        let delta = M_PI / Double(split)

        var vertices: [ModelVertex] = []

        let white: Float = 0.9
        let color = GLKVector4Make(white, white, white, 1)

        let texCoordA = GLKVector2Make(0, 0)
        let texCoordB = GLKVector2Make(0, 1)
        let texCoordC = GLKVector2Make(1, 1)
        let texCoordD = GLKVector2Make(1, 0)

        for y in 0..<split {
            for x in 0..<(split * 2) {
                let quaternion0 = GLKQuaternionMakeWithAngleAndAxis(Float(delta) * Float(x), 1, 0, 0)
                let quaternion1 = GLKQuaternionMakeWithAngleAndAxis(Float(delta) * Float(x + 1), 1, 0, 0)
                let theta0 = Float(delta) * Float(y)
                let theta1 = Float(delta) * Float(y + 1)

                let s = GLKQuaternionRotateVector3(quaternion0, GLKVector3Make(cos(theta0), sin(theta0), 0))
                let t = GLKQuaternionRotateVector3(quaternion1, GLKVector3Make(cos(theta0), sin(theta0), 0))
                let v = GLKQuaternionRotateVector3(quaternion1, GLKVector3Make(cos(theta1), sin(theta1), 0))
                let w = GLKQuaternionRotateVector3(quaternion0, GLKVector3Make(cos(theta1), sin(theta1), 0))

                let coordA = GLKVector3MultiplyScalar(s, r)
                let coordB = GLKVector3MultiplyScalar(t, r)
                let coordC = GLKVector3MultiplyScalar(v, r)
                let coordD = GLKVector3MultiplyScalar(w, r)

                let normalA = GLKVector3Normalize(GLKVector3MultiplyScalar(coordA, -1))
                let normalB = GLKVector3Normalize(GLKVector3MultiplyScalar(coordB, -1))
                let normalC = GLKVector3Normalize(GLKVector3MultiplyScalar(coordC, -1))
                let normalD = GLKVector3Normalize(GLKVector3MultiplyScalar(coordD, -1))

                let plane = [
                    ModelVertex(position: coordA, normal: normalA, color: color, texCoord: texCoordA),
                    ModelVertex(position: coordB, normal: normalB, color: color, texCoord: texCoordB),
                    ModelVertex(position: coordC, normal: normalC, color: color, texCoord: texCoordC),

                    ModelVertex(position: coordA, normal: normalA, color: color, texCoord: texCoordA),
                    ModelVertex(position: coordC, normal: normalC, color: color, texCoord: texCoordC),
                    ModelVertex(position: coordD, normal: normalD, color: color, texCoord: texCoordD),
                ]

                vertices.appendContentsOf(plane)
            }
        }

        localModelVertices = vertices
    }
}
