import Foundation

class Icosahedron {
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

    enum Side: String {
        case AB = "AB"
        case AC = "AC"
        case AE = "AE"
        case AF = "AF"
        case AG = "AG"
        case BC = "BC"
        case BD = "BD"
        case BF = "BF"
        case BH = "BH"
        case CD = "CD"
        case CE = "CE"
        case CI = "CI"
        case DH = "DH"
        case DI = "DI"
        case DJ = "DJ"
        case EI = "EI"
        case EK = "EK"
        case FG = "FG"
        case FH = "FH"
        case FL = "FL"
        case GE = "GE"
        case GK = "GK"
        case GL = "GL"
        case HJ = "HJ"
        case HL = "HL"
        case IJ = "IJ"
        case IK = "IK"
        case JK = "JK"
        case JL = "JL"
        case KL = "KL"

        static var values: [Side] {
            return [AB, AC, AE, AF, AG, BC, BD, BF, BH, CD, CE, CI, DH, DI, DJ, EI, EK, FG, FH, FL, GE, GK, GL, HJ, HL, IJ, IK, JK, JL, KL]
        }
    }
}
