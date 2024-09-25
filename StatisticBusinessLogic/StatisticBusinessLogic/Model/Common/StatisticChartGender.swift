
import Foundation
import UIKit

public enum StatisticChartGender {
    case male
    case female

    public var title: String {
        switch self {
        case .male: return "Мужчины"
        case .female: return "Женщины"
        }
    }

}
