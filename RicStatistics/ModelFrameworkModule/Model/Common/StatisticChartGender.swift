
import Foundation
import UIKit

enum StatisticChartGender {
    case male
    case female

    var title: String {
        switch self {
        case .male: return "Мужчины"
        case .female: return "Женщины"
        }
    }

    var color: UIColor {
        switch self {
        case .male: return .Charts.red
        case .female: return .Charts.orange
        }
    }
}
