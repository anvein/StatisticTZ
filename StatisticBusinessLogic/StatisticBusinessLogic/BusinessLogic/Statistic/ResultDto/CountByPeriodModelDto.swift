
import Foundation

public struct CountByPeriodModelDto {
    typealias WeakPeriod = (from: Date, to: Date)

    static let monthFormat = "MMyy"

    public let value: Int
    public var day: Date?
    var weak: WeakPeriod?
    var month: String?

}
