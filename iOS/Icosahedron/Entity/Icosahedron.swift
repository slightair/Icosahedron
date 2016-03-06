import Foundation

class Icosahedron {
    enum Point {
        case A
        case B
        case C
        case D
        case E
        case F
        case G
        case H
        case I
        case J
        case K
        case L

        static let values: [Point] = [A, B, C, D, E, F, G, H, I, J, K, L]
    }

    enum Side {
        case AB
        case AC
        case AE
        case AF
        case AG
        case BC
        case BD
        case BF
        case BH
        case CD
        case CE
        case CI
        case DH
        case DI
        case DJ
        case EI
        case EK
        case FG
        case FH
        case FL
        case GE
        case GK
        case GL
        case HJ
        case HL
        case IJ
        case IK
        case JK
        case JL
        case KL

        static let values: [Side] = [AB, AC, AE, AF, AG, BC, BD, BF, BH, CD, CE, CI, DH, DI, DJ, EI, EK, FG, FH, FL, GE, GK, GL, HJ, HL, IJ, IK, JK, JL, KL]
    }

    enum Face {
        case ABF
        case ACB
        case AEC
        case AFG
        case AGE
        case BCD
        case BDH
        case BHF
        case CEI
        case CID
        case DIJ
        case DJH
        case EGK
        case EKI
        case FHL
        case FLG
        case GLK
        case HJL
        case IKJ
        case JKL

        static let values: [Face] = [ABF, ACB, AEC, AFG, AGE, BCD, BDH, BHF, CEI, CID, DIJ, DJH, EGK, EKI, FHL, FLG, GLK, HJL, IKJ, JKL]
    }
}
