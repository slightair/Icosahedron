import Foundation

struct Track: CustomStringConvertible {
    let start: Icosahedron.Point
    let end: Icosahedron.Point
    let color: World.Color
    let turn: Int

    var description: String {
        return "\(start) -[\(color)](\(turn))-> \(end)"
    }

    var side: Icosahedron.Side {
        switch (start, end) {
        case (.A, .B), (.B, .A): return .AB
        case (.A, .C), (.C, .A): return .AC
        case (.A, .E), (.E, .A): return .AE
        case (.A, .F), (.F, .A): return .AF
        case (.A, .G), (.G, .A): return .AG
        case (.B, .C), (.C, .B): return .BC
        case (.B, .D), (.D, .B): return .BD
        case (.B, .F), (.F, .B): return .BF
        case (.B, .H), (.H, .B): return .BH
        case (.C, .D), (.D, .C): return .CD
        case (.C, .E), (.E, .C): return .CE
        case (.C, .I), (.I, .C): return .CI
        case (.D, .H), (.H, .D): return .DH
        case (.D, .I), (.I, .D): return .DI
        case (.D, .J), (.J, .D): return .DJ
        case (.E, .I), (.I, .E): return .EI
        case (.E, .K), (.K, .E): return .EK
        case (.F, .G), (.G, .F): return .FG
        case (.F, .H), (.H, .F): return .FH
        case (.F, .L), (.L, .F): return .FL
        case (.G, .E), (.E, .G): return .GE
        case (.G, .K), (.K, .G): return .GK
        case (.G, .L), (.L, .G): return .GL
        case (.H, .J), (.J, .H): return .HJ
        case (.H, .L), (.L, .H): return .HL
        case (.I, .J), (.J, .I): return .IJ
        case (.I, .K), (.K, .I): return .IK
        case (.J, .K), (.K, .J): return .JK
        case (.J, .L), (.L, .J): return .JL
        case (.K, .L), (.L, .K): return .KL
        default:
            fatalError("Unexpected combination (\(start) and \(end))")
        }
    }
}
