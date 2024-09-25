
import Foundation

public enum StatisticChartAgesRange: CaseIterable {
    case from18to21
    case from22to25
    case from26to30
    case from31to35
    case from36to40
    case from40to50
    case over50

    public var title: String {
        switch self {
        case .from18to21: return "18-21"
        case .from22to25: return "22-25"
        case .from26to30: return "26-30"
        case .from31to35: return "31-35"
        case .from36to40: return "36-40"
        case .from40to50: return "40-50"
        case .over50: return ">50"
        }
    }

    var from: Int {
        switch self {
        case .from18to21: return 18
        case .from22to25: return 22
        case .from26to30: return 26
        case .from31to35: return 31
        case .from36to40: return 36
        case .from40to50: return 40
        case .over50: return 51
        }
    }

    var to: Int {
        switch self {
        case .from18to21: return 21
        case .from22to25: return 25
        case .from26to30: return 30
        case .from31to35: return 35
        case .from36to40: return 40
        case .from40to50: return 50
        case .over50: return 130
        }
    }

    var order: Int {
        switch self {
        case .from18to21: return 1
        case .from22to25: return 2
        case .from26to30: return 3
        case .from31to35: return 4
        case .from36to40: return 5
        case .from40to50: return 6
        case .over50: return 7
        }
    }
}
