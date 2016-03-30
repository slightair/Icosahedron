import Foundation

class Phase {
    let number: Int
    let problems: [Symbol]

    init(number: Int) {
        self.number = number
        self.problems = Phase.problemsForPhaseNumber(number)
    }

    static func problemsForPhaseNumber(number: Int) -> [Symbol] {
        if number > Symbol.values.count {
            return Symbol.values
        }
        return Array(Symbol.values.prefix(number))
    }
}
