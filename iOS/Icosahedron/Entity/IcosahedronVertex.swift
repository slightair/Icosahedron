import Foundation
import GLKit

class IcosahedronVertex: CustomStringConvertible {
    enum Point: String {
        case A = "A"
        case B = "B"
        case C = "C"
        case D = "D"
        case E = "E"
        case F = "F"
        case G = "G"
        case H = "H"
        case I = "I"
        case J = "J"
        case K = "K"
        case L = "L"

        static var values: [Point] {
            return [A, B, C, D, E, F, G, H, I, J, K, L]
        }
    }

    let point: Point
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

    init(point: Point, coordinate: GLKVector3) {
        self.point = point
        self.coordinate = coordinate
    }
}
