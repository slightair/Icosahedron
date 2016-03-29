import GLKit

class IcosahedronFaceModel: Renderable {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]

    init(baseModelVertices: [ModelVertex], color: World.Color) {
        localModelVertices = baseModelVertices.map { vertex in
            vertex.changeColor(color.modelColor())
        }
    }
}
