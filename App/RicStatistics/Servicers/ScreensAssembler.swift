
import Foundation
import StatisticBusinessLogic

final class ScreensAssembler {
    func assemblyStatisticScreen() -> StatisticViewController {
        let model = StatisticsModel()
        return StatisticViewController(model: model)
    }
}
