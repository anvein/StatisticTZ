
import Foundation

struct VisitorsTrendModelDto {
    var countByPeriods: [Int] = []
    var trendType: TrendType = .flat
    var countInCurrentMonth: Int = 0
}
