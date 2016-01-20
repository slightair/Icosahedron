import GLKit
import Chameleon

class SphereModel: RenderablePolygon {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    var modelIndexes: [GLushort]

    init() {
        let split = 8
        let scale: Float = 0.2
        let faceColor = GLKVector4Make(1, 1, 1, 1)
        let texCoord = GLKVector2Make(0, 0)
        let delta = 2 * M_PI / Double(split)

        var vertices: [ModelVertex] = []

        for y in 0..<split {
            let radian = Float(delta) * Float(y)
            let quaternion = GLKQuaternionMakeWithAngleAndAxis(radian, 0, 1, 0)
            for x in 0..<split {
                let theta = delta * Double(x)
                let localCoord = GLKVector3MultiplyScalar(GLKVector3Make(Float(cos(theta)), Float(sin(theta)), 0), scale)
                let coord = GLKQuaternionRotateVector3(quaternion, localCoord)
                let normal = GLKVector3Normalize(coord)
                let vertex = ModelVertex(position: coord, normal: normal, color: faceColor, texCoord: texCoord)

                vertices.append(vertex)
            }
        }

        localModelVertices = vertices

        var indexes: [GLushort] = []
        for i in 0..<(split - 1) {
            for j in 0..<split {
                indexes.appendContentsOf([GLushort(j + i * split), GLushort(j + (i + 1) * split)])
            }
            indexes.append(GLushort((i + 2) * split - 1))
        }

        modelIndexes = indexes
    }
}
