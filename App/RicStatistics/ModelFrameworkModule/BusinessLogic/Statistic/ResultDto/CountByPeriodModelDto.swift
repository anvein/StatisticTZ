
import Foundation

struct CountByPeriodModelDto {
    typealias WeakPeriod = (from: Date, to: Date)

    static let monthFormat = "MMyy"

    let value: Int
    var day: Date?
    var weak: WeakPeriod?
    var month: String?

}
