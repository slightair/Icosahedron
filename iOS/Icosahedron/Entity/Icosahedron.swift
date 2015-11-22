import Foundation

struct Icosahedron {
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
}
