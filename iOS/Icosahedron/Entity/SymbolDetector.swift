import Foundation

class SymbolDetector {
    static let faceMaterials: [Set<Icosahedron.Side>: Icosahedron.Face] = [
        [.AB, .BC, .AC]: .ACB,
    ]

    static func facesFromTracks(tracks: [Track]) -> Set<Icosahedron.Face> {
        let sides = Set<Icosahedron.Side>(tracks.map { $0.side })
        var faces: Set<Icosahedron.Face> = []

        for (materials, face) in SymbolDetector.faceMaterials {
            let targetSides = sides.intersect(materials)

            if targetSides.count == 3 {
                faces.insert(face)
            }
        }

        return faces
    }
}
