import GLKit

class SphereModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    let scale: GLKVector3 = GLKVector3Make(1.0, 1.0, 1.0)
    let customColor: GLKVector4? = nil

    init() {
        let split = 32
        let scale: Float = 3
        let delta = M_PI / Double(split)

        var vertices: [ModelVertex] = []

        let color = GLKVector4Make(0.8, 0.8, 0.8, 1)

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

                let coordA = GLKVector3MultiplyScalar(s, scale)
                let coordB = GLKVector3MultiplyScalar(t, scale)
                let coordC = GLKVector3MultiplyScalar(v, scale)
                let coordD = GLKVector3MultiplyScalar(w, scale)

                let normalABC = createFaceNormal(coordA, y: coordB, z: coordC)
                let normalACD = createFaceNormal(coordA, y: coordC, z: coordD)

                let plane = [
                    ModelVertex(position: coordA, normal: normalABC, color: color, texCoord: texCoordA),
                    ModelVertex(position: coordB, normal: normalABC, color: color, texCoord: texCoordB),
                    ModelVertex(position: coordC, normal: normalABC, color: color, texCoord: texCoordC),

                    ModelVertex(position: coordA, normal: normalACD, color: color, texCoord: texCoordA),
                    ModelVertex(position: coordC, normal: normalACD, color: color, texCoord: texCoordC),
                    ModelVertex(position: coordD, normal: normalACD, color: color, texCoord: texCoordD),
                ]

                vertices.appendContentsOf(plane)
            }
        }

        localModelVertices = vertices
    }
}
