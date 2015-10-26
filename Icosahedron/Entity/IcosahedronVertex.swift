import Foundation
import GLKit

class IcosahedronVertex : NSObject {
    let name: String
    let coordinate: GLKVector3

    var head: IcosahedronVertex!
    var leftHand: IcosahedronVertex!
    var rightHand: IcosahedronVertex!
    var leftFoot: IcosahedronVertex!
    var rightFoot: IcosahedronVertex!

    var nextVertexNames: [String] {
        return [
            head.name,
            leftHand.name,
            leftFoot.name,
            rightFoot.name,
            rightHand.name,
        ]
    }

    override var description: String {
        return "\(name) \(NSStringFromGLKVector3(coordinate))"
    }

    init(name: String, coordinate: GLKVector3) {
        self.name = name
        self.coordinate = coordinate
    }
}
