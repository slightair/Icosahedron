import Foundation
import GameplayKit

class Phase {
    static let randomSource = GKMersenneTwisterRandomSource(seed: 3962)

    let number: Int
    let problems: [Symbol]

    init(number: Int) {
        self.number = number
        self.problems = Phase.problemsForPhaseNumber(number)
    }

    static func problemsForPhaseNumber(number: Int) -> [Symbol] {
        var cost = number
        var problems = [Symbol]()
        while cost > 0 {
            let candidates = Symbol.costs.filter { $0.1 <= cost }.map { ($0.0, $0.1) }

            let needle = randomSource.nextIntWithUpperBound(candidates.count)
            let (symbol, symbolCost) = candidates[needle]

            problems.append(symbol)
            cost -= symbolCost
        }

        return problems
    }
}
