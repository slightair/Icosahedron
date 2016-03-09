import XCTest

class TrackTests: XCTestCase {
    func testSide() {
        XCTAssertEqual(Track(start: .A, end: .B, color: .Red, turn: 0).side, Icosahedron.Side.AB)
        XCTAssertEqual(Track(start: .B, end: .A, color: .Red, turn: 0).side, Icosahedron.Side.AB)

        XCTAssertEqual(Track(start: .A, end: .C, color: .Red, turn: 0).side, Icosahedron.Side.AC)
        XCTAssertEqual(Track(start: .C, end: .A, color: .Red, turn: 0).side, Icosahedron.Side.AC)

        XCTAssertEqual(Track(start: .A, end: .E, color: .Red, turn: 0).side, Icosahedron.Side.AE)
        XCTAssertEqual(Track(start: .E, end: .A, color: .Red, turn: 0).side, Icosahedron.Side.AE)

        XCTAssertEqual(Track(start: .A, end: .F, color: .Red, turn: 0).side, Icosahedron.Side.AF)
        XCTAssertEqual(Track(start: .F, end: .A, color: .Red, turn: 0).side, Icosahedron.Side.AF)

        XCTAssertEqual(Track(start: .A, end: .G, color: .Red, turn: 0).side, Icosahedron.Side.AG)
        XCTAssertEqual(Track(start: .G, end: .A, color: .Red, turn: 0).side, Icosahedron.Side.AG)

        XCTAssertEqual(Track(start: .B, end: .C, color: .Red, turn: 0).side, Icosahedron.Side.BC)
        XCTAssertEqual(Track(start: .C, end: .B, color: .Red, turn: 0).side, Icosahedron.Side.BC)

        XCTAssertEqual(Track(start: .B, end: .D, color: .Red, turn: 0).side, Icosahedron.Side.BD)
        XCTAssertEqual(Track(start: .D, end: .B, color: .Red, turn: 0).side, Icosahedron.Side.BD)

        XCTAssertEqual(Track(start: .B, end: .F, color: .Red, turn: 0).side, Icosahedron.Side.BF)
        XCTAssertEqual(Track(start: .F, end: .B, color: .Red, turn: 0).side, Icosahedron.Side.BF)

        XCTAssertEqual(Track(start: .B, end: .H, color: .Red, turn: 0).side, Icosahedron.Side.BH)
        XCTAssertEqual(Track(start: .H, end: .B, color: .Red, turn: 0).side, Icosahedron.Side.BH)

        XCTAssertEqual(Track(start: .C, end: .D, color: .Red, turn: 0).side, Icosahedron.Side.CD)
        XCTAssertEqual(Track(start: .D, end: .C, color: .Red, turn: 0).side, Icosahedron.Side.CD)

        XCTAssertEqual(Track(start: .C, end: .E, color: .Red, turn: 0).side, Icosahedron.Side.CE)
        XCTAssertEqual(Track(start: .E, end: .C, color: .Red, turn: 0).side, Icosahedron.Side.CE)

        XCTAssertEqual(Track(start: .C, end: .I, color: .Red, turn: 0).side, Icosahedron.Side.CI)
        XCTAssertEqual(Track(start: .I, end: .C, color: .Red, turn: 0).side, Icosahedron.Side.CI)

        XCTAssertEqual(Track(start: .D, end: .H, color: .Red, turn: 0).side, Icosahedron.Side.DH)
        XCTAssertEqual(Track(start: .H, end: .D, color: .Red, turn: 0).side, Icosahedron.Side.DH)

        XCTAssertEqual(Track(start: .D, end: .I, color: .Red, turn: 0).side, Icosahedron.Side.DI)
        XCTAssertEqual(Track(start: .I, end: .D, color: .Red, turn: 0).side, Icosahedron.Side.DI)

        XCTAssertEqual(Track(start: .D, end: .J, color: .Red, turn: 0).side, Icosahedron.Side.DJ)
        XCTAssertEqual(Track(start: .J, end: .D, color: .Red, turn: 0).side, Icosahedron.Side.DJ)

        XCTAssertEqual(Track(start: .E, end: .I, color: .Red, turn: 0).side, Icosahedron.Side.EI)
        XCTAssertEqual(Track(start: .I, end: .E, color: .Red, turn: 0).side, Icosahedron.Side.EI)

        XCTAssertEqual(Track(start: .E, end: .K, color: .Red, turn: 0).side, Icosahedron.Side.EK)
        XCTAssertEqual(Track(start: .K, end: .E, color: .Red, turn: 0).side, Icosahedron.Side.EK)

        XCTAssertEqual(Track(start: .F, end: .G, color: .Red, turn: 0).side, Icosahedron.Side.FG)
        XCTAssertEqual(Track(start: .G, end: .F, color: .Red, turn: 0).side, Icosahedron.Side.FG)

        XCTAssertEqual(Track(start: .F, end: .H, color: .Red, turn: 0).side, Icosahedron.Side.FH)
        XCTAssertEqual(Track(start: .H, end: .F, color: .Red, turn: 0).side, Icosahedron.Side.FH)

        XCTAssertEqual(Track(start: .F, end: .L, color: .Red, turn: 0).side, Icosahedron.Side.FL)
        XCTAssertEqual(Track(start: .L, end: .F, color: .Red, turn: 0).side, Icosahedron.Side.FL)

        XCTAssertEqual(Track(start: .G, end: .E, color: .Red, turn: 0).side, Icosahedron.Side.GE)
        XCTAssertEqual(Track(start: .E, end: .G, color: .Red, turn: 0).side, Icosahedron.Side.GE)

        XCTAssertEqual(Track(start: .G, end: .K, color: .Red, turn: 0).side, Icosahedron.Side.GK)
        XCTAssertEqual(Track(start: .K, end: .G, color: .Red, turn: 0).side, Icosahedron.Side.GK)

        XCTAssertEqual(Track(start: .G, end: .L, color: .Red, turn: 0).side, Icosahedron.Side.GL)
        XCTAssertEqual(Track(start: .L, end: .G, color: .Red, turn: 0).side, Icosahedron.Side.GL)

        XCTAssertEqual(Track(start: .H, end: .J, color: .Red, turn: 0).side, Icosahedron.Side.HJ)
        XCTAssertEqual(Track(start: .J, end: .H, color: .Red, turn: 0).side, Icosahedron.Side.HJ)

        XCTAssertEqual(Track(start: .H, end: .L, color: .Red, turn: 0).side, Icosahedron.Side.HL)
        XCTAssertEqual(Track(start: .L, end: .H, color: .Red, turn: 0).side, Icosahedron.Side.HL)

        XCTAssertEqual(Track(start: .I, end: .J, color: .Red, turn: 0).side, Icosahedron.Side.IJ)
        XCTAssertEqual(Track(start: .J, end: .I, color: .Red, turn: 0).side, Icosahedron.Side.IJ)

        XCTAssertEqual(Track(start: .I, end: .K, color: .Red, turn: 0).side, Icosahedron.Side.IK)
        XCTAssertEqual(Track(start: .K, end: .I, color: .Red, turn: 0).side, Icosahedron.Side.IK)

        XCTAssertEqual(Track(start: .J, end: .K, color: .Red, turn: 0).side, Icosahedron.Side.JK)
        XCTAssertEqual(Track(start: .K, end: .J, color: .Red, turn: 0).side, Icosahedron.Side.JK)

        XCTAssertEqual(Track(start: .J, end: .L, color: .Red, turn: 0).side, Icosahedron.Side.JL)
        XCTAssertEqual(Track(start: .L, end: .J, color: .Red, turn: 0).side, Icosahedron.Side.JL)

        XCTAssertEqual(Track(start: .K, end: .L, color: .Red, turn: 0).side, Icosahedron.Side.KL)
        XCTAssertEqual(Track(start: .L, end: .K, color: .Red, turn: 0).side, Icosahedron.Side.KL)
    }
}
