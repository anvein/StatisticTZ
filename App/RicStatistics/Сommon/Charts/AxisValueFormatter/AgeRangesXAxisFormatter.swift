
import DGCharts

final class AgeRangesXAxisFormatter: IndexAxisValueFormatter {

    private let agesRanges: [StatisticChartAgesRange]

    init(agesRanges: [StatisticChartAgesRange]) {
        self.agesRanges = agesRanges
        super.init()
    }

    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        if index % 2 == 0 {
            let arrayIndex = Int(index / 2)
            return agesRanges[safe: arrayIndex]?.title ?? ""
        }

        return ""
    }
}
