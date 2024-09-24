
import Foundation

final class DateStatisticsService {

    /// Key (String) - дата в виде "mmYY"
    /// Value (Int) - количество в указанный месяц
    typealias CountsByMonts = (month: String, count: Int)
    

    static let countByMontsDateFormat = "MMYY"

    // MARK: - Methods

    func calculateDatesCountByMonts(fromDates dates: [Date], countMonth: Int) -> [CountsByMonts] {
        let currentDate = Date()
        let calendar = Calendar.current

        var countByMonth: [CountsByMonts] = []

        for iMonth in 1...countMonth {
            let currentDayInMonth = calendar.date(byAdding: .month, value: -iMonth, to: calendar.startOfDay(for: currentDate))

            guard let currentDayInMonth else { continue }
            let monthStart = calendar.date(bySetting: .day, value: 1, of: currentDayInMonth)
            guard let monthStart else { continue }

            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)
            guard let monthEnd else { continue }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Self.countByMontsDateFormat

            let monthKey = dateFormatter.string(from: monthStart)
            let count = dates.filter {
                return $0 > monthStart && $0 <= monthEnd
            }.count

            countByMonth.append((month: monthKey, count: count))
        }

        return countByMonth
    }

    func calculateDeltaForLastMonth(countsByMonths: [CountsByMonts]) -> Int? {
        let lastMonthCount = countsByMonths[safe: 0]
        let prevMonthCount = countsByMonths[safe: 1]

        guard let lastMonthCount, let prevMonthCount else { return nil }

        return lastMonthCount.count - prevMonthCount.count
    }

    func calculateTrendTypeFor(delta: Int) -> TrendType {
        var trendType: TrendType
        if delta > 0 {
            return .up
        } else if delta < 0 {
            return .down
        } else {
            return .flat
        }
    }
}
