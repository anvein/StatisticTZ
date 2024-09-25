
import Foundation

final class ScreensAssembler {
    func assemblyStatisticScreen() -> StatisticViewController {
        let model = StatisticsModel()
        return StatisticViewController(model: model)
    }
}
