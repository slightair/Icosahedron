import Foundation

class SymbolDetector {
    static let faceMaterials: [Set<Icosahedron.Side>: Icosahedron.Face] = [
        [.AB, .AF, .BF]: .ABF,
        [.AB, .AC, .BC]: .ACB,
        [.AC, .AE, .CE]: .AEC,
        [.AF, .AG, .FG]: .AFG,
        [.AE, .AG, .GE]: .AGE,
        [.BC, .BD, .CD]: .BCD,
        [.BD, .BH, .DH]: .BDH,
        [.BF, .BH, .FH]: .BHF,
        [.CE, .CI, .EI]: .CEI,
        [.CD, .CI, .DI]: .CID,
        [.DI, .DJ, .IJ]: .DIJ,
        [.DH, .DJ, .HJ]: .DJH,
        [.EK, .GE, .GK]: .EGK,
        [.EI, .EK, .IK]: .EKI,
        [.FH, .FL, .HL]: .FHL,
        [.FG, .FL, .GL]: .FLG,
        [.GK, .GL, .KL]: .GLK,
        [.HJ, .HL, .JL]: .HJL,
        [.IJ, .IK, .JK]: .IKJ,
        [.JK, .JL, .KL]: .JKL,
    ]

    static func facesFromTracks(tracks: [Track]) -> Set<Icosahedron.Face> {
        var faces: Set<Icosahedron.Face> = []

        for (materials, face) in SymbolDetector.faceMaterials {
            let targetTracks = tracks.filter { materials.contains($0.side) }
            let targetColors = Set<World.Color>(targetTracks.map { $0.color })

            if targetTracks.count == 3 && targetColors.count == 1 {
                faces.insert(face)
            }
        }

        return faces
    }
}
