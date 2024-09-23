
import Foundation

enum VisitorsStatisticPeriod: CaseIterable {
    case byDay
    case byWeek
    case byMonth
}

// MARK: - StatisticPeriod

extension VisitorsStatisticPeriod: StatisticPeriod {
    var title: String {
        switch self {
        case .byDay: return "По дням" // TODO: lang
        case .byWeek: return "По неделям"
        case .byMonth: return "По месяцам"
        }
    }
}
