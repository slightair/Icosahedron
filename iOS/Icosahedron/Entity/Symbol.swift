import Foundation

enum Symbol {
    case RedTriangle
    case GreenTriangle
    case BlueTriangle
    case RedRhombus
    case GreenRhombus
    case BlueRhombus
    case RedSuperTriangle
    case GreenSuperTriangle
    case BlueSuperTriangle
    case FullColorSuperTriangle

    static let values: [Symbol] = [
        .RedTriangle,
        .GreenTriangle,
        .BlueTriangle,
        .RedRhombus,
        .GreenRhombus,
        .BlueRhombus,
        .RedSuperTriangle,
        .GreenSuperTriangle,
        .BlueSuperTriangle,
        .FullColorSuperTriangle,
    ]
}
