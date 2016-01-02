import Foundation
import RxSwift

class LevelLabelModel: LabelModel {
    init() {
        super.init(text: "Lv 1")
    }

    var rx_level: AnyObserver<Int> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()

            switch event {
            case .Next(let value):
                if value >= World.needExpList.count - 1 {
                    self?.text = "Lv Max"
                } else {
                    self?.text = "Lv \(value)"
                }
            case .Error(let error):
                fatalError("Binding error to UI: \(error)")
                break
            case .Completed:
                break
            }
        }
    }
}
