
import Foundation

enum StatisticByGenderAndAgePeriod: CaseIterable {
    case today
    case week
    case month
    case allTime
}

// MARK: - StatisticPeriod

extension StatisticByGenderAndAgePeriod: StatisticPeriod {
    var title: String {
        switch self {
        case .today: return "Сегодня" // TODO: lang
        case .week: return "Неделя"
        case .month: return "Месяц"
        case .allTime: return "Все время"
        }
    }
}
