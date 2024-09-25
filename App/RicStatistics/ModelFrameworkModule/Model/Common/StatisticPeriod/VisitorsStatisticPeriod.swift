
import Foundation

enum VisitorsStatisticPeriod: CaseIterable {
    case byDay
    case byWeek
    case byMonth

    var periodLength: Int {
        switch self {
        case .byDay: return 90
        case .byWeek: return 48
        case .byMonth: return 12
        }
    }
}

// MARK: - StatisticPeriod

extension VisitorsStatisticPeriod: StatisticPeriod {
    var title: String {
        switch self {
        case .byDay: return "По дням" 
        case .byWeek: return "По неделям"
        case .byMonth: return "По месяцам"
        }
    }
}
