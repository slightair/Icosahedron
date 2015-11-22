import Foundation
import GLKit

class IcosahedronVertex: CustomStringConvertible {
    let point: Icosahedron.Point
    let coordinate: GLKVector3

    var head: IcosahedronVertex!
    var leftHand: IcosahedronVertex!
    var rightHand: IcosahedronVertex!
    var leftFoot: IcosahedronVertex!
    var rightFoot: IcosahedronVertex!

    var nextVertices: [IcosahedronVertex] {
        return [
            head,
            leftHand,
            leftFoot,
            rightFoot,
            rightHand,
        ]
    }

    var nextVertexNames: [String] {
        return nextVertices.map { $0.point.rawValue }
    }

    var description: String {
        return "\(point.rawValue) \(NSStringFromGLKVector3(coordinate))"
    }

    init(point: Icosahedron.Point, coordinate: GLKVector3) {
        self.point = point
        self.coordinate = coordinate
    }
}
