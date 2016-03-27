import GLKit

class ProblemModelGroup {
    var position = GLKVector3Make(0.0, 0.0, 0.0) {
        didSet {
            for (index, model) in symbolModels.enumerate() {
                let margin: Float = 0.005
                model.position = GLKVector3Make(position.x + Float(index) * (SymbolModel.size + margin), position.y, 0.0)
            }
        }
    }
    var symbolModels: [SymbolModel]

    init(problem: [Symbol]) {
        symbolModels = problem.map {
            SymbolModel(symbol: $0)
        }
    }
}
