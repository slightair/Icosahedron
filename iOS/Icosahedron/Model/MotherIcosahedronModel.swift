import GLKit

class MotherIcosahedronModel: IcosahedronModel {
    override class var scale: Float {
        return 0.15
    }

    var pointDict: [Icosahedron.Point: IcosahedronVertex] = [:]

    func coordinateOfPoint(point: Icosahedron.Point) -> GLKVector3 {
        guard let vertex = pointDict[point] else {
            fatalError("unexpected Point")
        }
        return vertex.coordinate
    }

    override init() {
        super.init()

        for vertex in icosahedronVertices {
            pointDict[vertex.point] = vertex
        }

        pointDict[.C]!.head      = pointDict[.I]
        pointDict[.C]!.leftHand  = pointDict[.D]
        pointDict[.C]!.leftFoot  = pointDict[.B]
        pointDict[.C]!.rightHand = pointDict[.E]
        pointDict[.C]!.rightFoot = pointDict[.A]

        pointDict[.B]!.head      = pointDict[.A]
        pointDict[.B]!.leftHand  = pointDict[.C]
        pointDict[.B]!.leftFoot  = pointDict[.D]
        pointDict[.B]!.rightHand = pointDict[.H]
        pointDict[.B]!.rightFoot = pointDict[.F]

        pointDict[.A]!.head      = pointDict[.E]
        pointDict[.A]!.leftHand  = pointDict[.C]
        pointDict[.A]!.leftFoot  = pointDict[.B]
        pointDict[.A]!.rightHand = pointDict[.F]
        pointDict[.A]!.rightFoot = pointDict[.G]

        pointDict[.E]!.head      = pointDict[.G]
        pointDict[.E]!.leftHand  = pointDict[.K]
        pointDict[.E]!.leftFoot  = pointDict[.I]
        pointDict[.E]!.rightHand = pointDict[.C]
        pointDict[.E]!.rightFoot = pointDict[.A]

        pointDict[.G]!.head      = pointDict[.L]
        pointDict[.G]!.leftHand  = pointDict[.K]
        pointDict[.G]!.leftFoot  = pointDict[.E]
        pointDict[.G]!.rightHand = pointDict[.A]
        pointDict[.G]!.rightFoot = pointDict[.F]

        pointDict[.L]!.head      = pointDict[.F]
        pointDict[.L]!.leftHand  = pointDict[.H]
        pointDict[.L]!.leftFoot  = pointDict[.J]
        pointDict[.L]!.rightHand = pointDict[.K]
        pointDict[.L]!.rightFoot = pointDict[.G]

        pointDict[.F]!.head      = pointDict[.H]
        pointDict[.F]!.leftHand  = pointDict[.L]
        pointDict[.F]!.leftFoot  = pointDict[.G]
        pointDict[.F]!.rightHand = pointDict[.A]
        pointDict[.F]!.rightFoot = pointDict[.B]

        pointDict[.H]!.head      = pointDict[.J]
        pointDict[.H]!.leftHand  = pointDict[.L]
        pointDict[.H]!.leftFoot  = pointDict[.F]
        pointDict[.H]!.rightHand = pointDict[.B]
        pointDict[.H]!.rightFoot = pointDict[.D]

        pointDict[.J]!.head      = pointDict[.K]
        pointDict[.J]!.leftHand  = pointDict[.L]
        pointDict[.J]!.leftFoot  = pointDict[.H]
        pointDict[.J]!.rightHand = pointDict[.D]
        pointDict[.J]!.rightFoot = pointDict[.I]

        pointDict[.K]!.head      = pointDict[.I]
        pointDict[.K]!.leftHand  = pointDict[.E]
        pointDict[.K]!.leftFoot  = pointDict[.G]
        pointDict[.K]!.rightHand = pointDict[.L]
        pointDict[.K]!.rightFoot = pointDict[.J]

        pointDict[.I]!.head      = pointDict[.D]
        pointDict[.I]!.leftHand  = pointDict[.C]
        pointDict[.I]!.leftFoot  = pointDict[.E]
        pointDict[.I]!.rightHand = pointDict[.K]
        pointDict[.I]!.rightFoot = pointDict[.J]

        pointDict[.D]!.head      = pointDict[.C]
        pointDict[.D]!.leftHand  = pointDict[.I]
        pointDict[.D]!.leftFoot  = pointDict[.J]
        pointDict[.D]!.rightHand = pointDict[.H]
        pointDict[.D]!.rightFoot = pointDict[.B]
    }
}
