
import Foundation
import DGCharts

final class DatesXAxisFormatter: AxisValueFormatter {

    private let dates: [Date]
    private let dateFormatter: DateFormatter

    init(dates: [Date], dateFormatter: DateFormatter) {
        self.dates = dates
        self.dateFormatter = dateFormatter
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        guard index >= 0, let date = dates[safe: index] else { return "" }

        return dateFormatter.string(from: date)

    }
}
