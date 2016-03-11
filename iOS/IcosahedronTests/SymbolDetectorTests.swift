import XCTest

class SymbolDetectorTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

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

        XCTAssertEqual(faces, [.ACB])
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

        XCTAssertEqual(faces, [.ACB, .AFG])
    }

    func testFacesFromTracksHasOneFaceReverse() {
        let tracks: [Track] = [
            Track(start: .A, end: .B, color: .Red, turn:1),
            Track(start: .B, end: .C, color: .Red, turn:2),
            Track(start: .C, end: .A, color: .Red, turn:3),
        ]
        let faces = SymbolDetector.facesFromTracks(tracks)

        XCTAssertEqual(faces, [.ACB])
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

        XCTAssertEqual(faces, [.ACB, .BCD])
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

        XCTAssertEqual(faces, [.ACB, .BCD, .CID, .BDH])
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

        XCTAssertEqual(faces, [.ACB, .CID, .BDH])
    }
}
