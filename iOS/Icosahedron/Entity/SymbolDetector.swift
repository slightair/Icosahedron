import Foundation

func == (lhs: SymbolDetector.Face, rhs: SymbolDetector.Face) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class SymbolDetector {
    struct Face: Hashable {
        let face: Icosahedron.Face
        let color: World.Color

        var hashValue: Int {
            return "\(face)/\(color)".hashValue
        }
    }

    static let faceMaterials: [Icosahedron.Face: Set<Icosahedron.Side>] = [
        .ABF: [.AB, .AF, .BF],
        .ACB: [.AB, .AC, .BC],
        .AEC: [.AC, .AE, .CE],
        .AFG: [.AF, .AG, .FG],
        .AGE: [.AE, .AG, .GE],
        .BCD: [.BC, .BD, .CD],
        .BDH: [.BD, .BH, .DH],
        .BHF: [.BF, .BH, .FH],
        .CEI: [.CE, .CI, .EI],
        .CID: [.CD, .CI, .DI],
        .DIJ: [.DI, .DJ, .IJ],
        .DJH: [.DH, .DJ, .HJ],
        .EGK: [.EK, .GE, .GK],
        .EKI: [.EI, .EK, .IK],
        .FHL: [.FH, .FL, .HL],
        .FLG: [.FG, .FL, .GL],
        .GLK: [.GK, .GL, .KL],
        .HJL: [.HJ, .HL, .JL],
        .IKJ: [.IJ, .IK, .JK],
        .JKL: [.JK, .JL, .KL],
    ]

    static func facesFromTracks(tracks: [Track]) -> Set<Face> {
        var faces: Set<Face> = []

        for (face, materials) in SymbolDetector.faceMaterials {
            let targetTracks = tracks.filter { materials.contains($0.side) }
            let targetColors = Set<World.Color>(targetTracks.map { $0.color })

            if targetTracks.count == 3 && targetColors.count == 1 {
                faces.insert(Face(face: face, color: targetColors.first!))
            }
        }

        return faces
    }

    static func symbolsFromTracks(tracks: [Track]) -> Set<Symbol> {
        var symbols: Set<Symbol> = []
        var faces: Set<Face> = []

        for (face, materials) in SymbolDetector.faceMaterials {
            let targetTracks = tracks.filter { materials.contains($0.side) }
            let targetColors = Set<World.Color>(targetTracks.map { $0.color })

            if targetTracks.count == 3 && targetColors.count == 1 {
                faces.insert(Face(face: face, color: targetColors.first!))

                let triangle: Symbol
                switch targetColors.first! {
                case .Red:
                    triangle = .RedTriangle
                case .Green:
                    triangle = .GreenTriangle
                case .Blue:
                    triangle = .BlueTriangle
                }
                symbols.insert(triangle)
            }
        }

        func rhombusForColor(color: World.Color) -> Symbol {
            switch color {
            case .Red:
                return .RedRhombus
            case .Green:
                return .GreenRhombus
            case .Blue:
                return .BlueRhombus
            }
        }

        for color in World.Color.values {
            let triangles = faces.filter { $0.color == color }
            for triangle in triangles {
                for other in (triangles.filter { $0 != triangle }) {
                    let triangleSides = faceMaterials[triangle.face]!
                    let otherSides = faceMaterials[other.face]!
                    let sides = triangleSides.union(otherSides)
                    if sides.count == 5 {
                        symbols.insert(rhombusForColor(color))
                    }
                }
            }
        }

        return symbols
    }
}
