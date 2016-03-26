import XCTest

class SymbolDetectorDetectFacesTests: XCTestCase {
    func testFacesFromTracksEmpty() {
        let tracks: [Track] = []
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [])
    }

    func testFacesFromTracksHasNotFace() {
        let tracks: [Track] = [
            Track(start: .A, end: .B, color: .Red, turn:1),
        ]
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [])
    }

    func testFacesFromTracksHasOneFace() {
        let tracks: [Track] = [
            Track(start: .A, end: .C, color: .Red, turn:1),
            Track(start: .C, end: .B, color: .Red, turn:2),
            Track(start: .B, end: .A, color: .Red, turn:3),
        ]
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [
            SymbolDetector.Face(face: .ACB, color: .Red),
        ])
    }

    func testFacesFromTracksHasNotFacesColorDifferent() {
        let tracks: [Track] = [
            Track(start: .A, end: .C, color: .Red, turn:1),
            Track(start: .C, end: .B, color: .Green, turn:2),
            Track(start: .B, end: .A, color: .Blue, turn:3),
        ]
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [])
    }

    func testFacesFromTracksHasTwoFaces() {
        let tracks: [Track] = [
            Track(start: .A, end: .C, color: .Red, turn:1),
            Track(start: .C, end: .B, color: .Red, turn:2),
            Track(start: .B, end: .A, color: .Red, turn:3),
            Track(start: .A, end: .F, color: .Green, turn:4),
            Track(start: .F, end: .G, color: .Green, turn:5),
            Track(start: .G, end: .A, color: .Green, turn:6),
        ]
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [
            SymbolDetector.Face(face: .ACB, color: .Red),
            SymbolDetector.Face(face: .AFG, color: .Green),
        ])
    }

    func testFacesFromTracksHasOneFaceReverse() {
        let tracks: [Track] = [
            Track(start: .A, end: .B, color: .Red, turn:1),
            Track(start: .B, end: .C, color: .Red, turn:2),
            Track(start: .C, end: .A, color: .Red, turn:3),
        ]
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [
            SymbolDetector.Face(face: .ACB, color: .Red),
        ])
    }

    func testFacesFromTracksHasTwoFacesRhombus() {
        let tracks: [Track] = [
            Track(start: .B, end: .A, color: .Red, turn:1),
            Track(start: .A, end: .C, color: .Red, turn:2),
            Track(start: .C, end: .B, color: .Red, turn:3),
            Track(start: .B, end: .D, color: .Red, turn:4),
            Track(start: .D, end: .C, color: .Red, turn:5),
        ]
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [
            SymbolDetector.Face(face: .ACB, color: .Red),
            SymbolDetector.Face(face: .BCD, color: .Red),
        ])
    }

    func testFacesFromTracksHasTwoFacesRhombus2() {
        let tracks: [Track] = [
            Track(start: .C, end: .I, color: .Green, turn:1),
            Track(start: .E, end: .K, color: .Green, turn:3),
            Track(start: .K, end: .I, color: .Green, turn:4),
            Track(start: .I, end: .E, color: .Green, turn:5),
            Track(start: .E, end: .C, color: .Green, turn:6),
        ]
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [
            SymbolDetector.Face(face: .CEI, color: .Green),
            SymbolDetector.Face(face: .EKI, color: .Green),
        ])
    }

    func testFacesFromTracksHasFourFacesSuperTriangle() {
        let tracks: [Track] = [
            Track(start: .C, end: .B, color: .Red, turn:1),
            Track(start: .B, end: .A, color: .Red, turn:2),
            Track(start: .A, end: .C, color: .Red, turn:3),
            Track(start: .C, end: .I, color: .Red, turn:4),
            Track(start: .I, end: .D, color: .Red, turn:5),
            Track(start: .D, end: .H, color: .Red, turn:6),
            Track(start: .H, end: .B, color: .Red, turn:7),
            Track(start: .B, end: .D, color: .Red, turn:8),
            Track(start: .D, end: .C, color: .Red, turn:9),
        ]
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [
            SymbolDetector.Face(face: .ACB, color: .Red),
            SymbolDetector.Face(face: .BCD, color: .Red),
            SymbolDetector.Face(face: .CID, color: .Red),
            SymbolDetector.Face(face: .BDH, color: .Red),
        ])
    }

    func testFacesFromTracksHasThreeFacesSuperTriangleFullColor() {
        let tracks: [Track] = [
            Track(start: .C, end: .B, color: .Red, turn:1),
            Track(start: .B, end: .A, color: .Red, turn:2),
            Track(start: .A, end: .C, color: .Red, turn:3),
            Track(start: .C, end: .I, color: .Green, turn:4),
            Track(start: .I, end: .D, color: .Green, turn:5),
            Track(start: .D, end: .H, color: .Blue, turn:6),
            Track(start: .H, end: .B, color: .Blue, turn:7),
            Track(start: .B, end: .D, color: .Blue, turn:8),
            Track(start: .D, end: .C, color: .Green, turn:9),
        ]
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [
            SymbolDetector.Face(face: .ACB, color: .Red),
            SymbolDetector.Face(face: .CID, color: .Green),
            SymbolDetector.Face(face: .BDH, color: .Blue),
        ])
    }
}
