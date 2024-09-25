
import Foundation
import DGCharts

final class CustomLabelsXAxisFormatter: AxisValueFormatter {

    private let labelsTexts: [String]

    init(labelsTexts: [String]) {
        self.labelsTexts = labelsTexts
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        guard index >= 0, let text = labelsTexts[safe: index] else { return "" }

        return text

    }
}
