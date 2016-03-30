import GLKit

class ProblemModelGroup {
    var position = GLKVector3Make(0.0, 0.0, 0.0)

    var problems: [Symbol] = [] {
        didSet {
            symbolModels = problems.enumerate().map { index, problem in
                let margin: Float = 0.005
                let model = SymbolModel(symbol: problem)
                model.position = GLKVector3Make(position.x + Float(index) * (SymbolModel.size + margin), position.y, 0.0)
                return model
            }
        }
    }

    var symbolModels: [SymbolModel] = []
}
