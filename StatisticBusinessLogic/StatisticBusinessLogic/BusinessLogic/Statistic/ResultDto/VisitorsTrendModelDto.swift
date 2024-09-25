
import Foundation

public struct VisitorsTrendModelDto {
    public var countByPeriods: [Int] = []
    public var trendType: TrendType = .flat
    public var countInCurrentMonth: Int = 0
}
