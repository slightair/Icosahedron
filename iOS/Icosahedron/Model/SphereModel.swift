import GLKit
import Chameleon

class SphereModel: RenderablePolygon {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    var modelIndexes: [GLushort]

    init() {
        let split = 32
        let scale: Float = 1.2
        let delta = M_PI / Double(split - 1)

        var vertices: [ModelVertex] = []

        for y in 0...((split - 1) * 2) {
            let radian = Float(delta) * Float(y)
            let quaternion = GLKQuaternionMakeWithAngleAndAxis(radian, 1, 0, 0)
            for x in 0..<split {
                let theta = delta * Double(x)
                let localCoord = GLKVector3MultiplyScalar(GLKVector3Make(Float(cos(theta)), Float(sin(theta)), 0), scale)
                let coord = GLKQuaternionRotateVector3(quaternion, localCoord)
                let normal = GLKVector3Normalize(GLKVector3MultiplyScalar(coord, -1))
                let color = GLKVector4Make(Float(cos(theta)), Float(sin(theta)), 1, 1)

                let texCoordX: Float = x % 2 == 0 ? 0.0 : 1.0
                let texCoordY: Float = y % 2 == 0 ? 0.0 : 1.0
                let texCoord = GLKVector2Make(texCoordX, texCoordY)

                let vertex = ModelVertex(position: coord, normal: normal, color: color, texCoord: texCoord)

                vertices.append(vertex)
            }
        }

        localModelVertices = vertices

        var indexes: [GLushort] = []
        for i in 0..<((split - 1) * 2) {
            for j in 0..<split {
                indexes.appendContentsOf([GLushort(j + i * split), GLushort(j + (i + 1) * split)])
            }
            indexes.append(GLushort((i + 2) * split - 1))
        }

        modelIndexes = indexes
    }
}
