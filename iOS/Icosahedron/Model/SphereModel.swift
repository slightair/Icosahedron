import GLKit
import Chameleon

class SphereModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    let customColor: GLKVector4? = nil

    init() {
        let split = 4
        let scale: Float = 0.3 // 3.0
        let texCoord = GLKVector2Make(0, 0)
        let delta = M_PI / Double(split - 1)

        var coordinates: [GLKVector3] = []

        for y in 0...((split - 1) * 2) {
            let radian = Float(delta) * Float(y)
            let quaternion = GLKQuaternionMakeWithAngleAndAxis(radian, 1, 0, 0)
            for x in 0..<split {
                let theta = delta * Double(x)
                let localCoord = GLKVector3MultiplyScalar(GLKVector3Make(Float(cos(theta)), Float(sin(theta)), 0), scale)
                let coord = GLKQuaternionRotateVector3(quaternion, localCoord)
                coordinates.append(coord)
            }
        }

        var indexes: [Int] = []
        for i in 0..<((split - 1) * 2) {
            for j in 0..<split {
                indexes.appendContentsOf([j + i * split, j + (i + 1) * split])
            }
            indexes.append((i + 2) * split - 1)
        }

        var vertices: [ModelVertex] = []

        let colors = [
            GLKVector4Make(1, 0, 0, 1),
            GLKVector4Make(0, 1, 0, 1),
            GLKVector4Make(0, 0, 1, 1),
        ]

        for i in 0..<(indexes.count - 2) {
            let triangleCoordinates = [
                coordinates[indexes[i]],
                coordinates[indexes[i + 1]],
                coordinates[indexes[i + 2]],
            ]

            let normal: GLKVector3
            if i % 2 == 0 {
                normal = createFaceNormal(triangleCoordinates[0], y: triangleCoordinates[1], z: triangleCoordinates[2])
            } else {
                normal = createFaceNormal(triangleCoordinates[2], y: triangleCoordinates[1], z: triangleCoordinates[0])
            }

            for j in 0..<3 {
                let coord = triangleCoordinates[j]
                let color = colors[j % colors.count]
                let vertex = ModelVertex(position: coord, normal: normal, color: color, texCoord: texCoord)

                vertices.append(vertex)
            }
        }

        localModelVertices = vertices
    }
}
