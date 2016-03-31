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

    static let costs: [Symbol: Int] = [
        .RedTriangle: 1,
        .GreenTriangle: 1,
        .BlueTriangle: 1,
        .RedRhombus: 5,
        .GreenRhombus: 5,
        .BlueRhombus: 5,
        .RedSuperTriangle: 15,
        .GreenSuperTriangle: 15,
        .BlueSuperTriangle: 15,
        .FullColorSuperTriangle: 50,
    ]
}
