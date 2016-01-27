import GLKit

class CanvasModel: RenderablePolygon {
    var position = GLKVector3Make(0.0, 0.0, 0.0)
    var quaternion = GLKQuaternionIdentity
    var localModelVertices: [ModelVertex]
    var modelIndexes: [GLushort]

    init() {
        let normal = GLKVector3Make(0, 0, -1)
        localModelVertices = [
            ModelVertex(position: GLKVector3Make(-1, -1, 0), normal: normal, color: GLKVector4Make(1, 1, 1, 1), texCoord: GLKVector2Make(0, 0)),
            ModelVertex(position: GLKVector3Make(-1,  1, 0), normal: normal, color: GLKVector4Make(1, 1, 1, 1), texCoord: GLKVector2Make(0, 1)),
            ModelVertex(position: GLKVector3Make( 1, -1, 0), normal: normal, color: GLKVector4Make(1, 1, 1, 1), texCoord: GLKVector2Make(1, 0)),
            ModelVertex(position: GLKVector3Make( 1,  1, 0), normal: normal, color: GLKVector4Make(1, 1, 1, 1), texCoord: GLKVector2Make(1, 1)),
        ]
        modelIndexes = [0, 1, 2, 3]
    }
}
