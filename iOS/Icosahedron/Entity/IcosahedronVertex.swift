import Foundation
import GLKit

class IcosahedronVertex: CustomStringConvertible {
    let name: String
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
        return nextVertices.map { $0.name }
    }

    var description: String {
        return "\(name) \(NSStringFromGLKVector3(coordinate))"
    }

    init(name: String, coordinate: GLKVector3) {
        self.name = name
        self.coordinate = coordinate
    }
}
