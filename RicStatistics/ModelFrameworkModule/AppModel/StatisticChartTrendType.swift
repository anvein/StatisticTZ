
import Foundation
import UIKit

enum StatisticChartTrendType {
    case up
    case down

    var color: UIColor {
        switch self {
        case .up: return .Charts.green
        case .down: return .Charts.red
        }
    }
}
