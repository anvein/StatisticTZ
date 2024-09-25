
import UIKit
import DGCharts
import StatisticBusinessLogic

final class StatisticGenderPieChartView: PieChartView {

    typealias ChartItem = (gender: StatisticChartGender, value: Double)

    // MARK: - Data

    private var chartData: [ChartItem] = []

    // MARK: - Init

    convenience init() {
        self.init(frame: .zero)
        setup()

        // TODO: удалить наполнение данных
        setDataAndReload(data: [(.female, 60), (.male, 40)], animate: false)
        ///
    }

    // MARK: - Update view

    func setDataAndReload(data: [ChartItem], animate: Bool) {
        chartData = data
        chartData.sort { $0.value > $1.value }
        reloadChart(withAnimate: animate)
    }

}

private extension StatisticGenderPieChartView {

    // MARK: - Setup

    func setup() {
        holeRadiusPercent = 0.88
        drawEntryLabelsEnabled = false
        rotationEnabled = false

        legend.font = .gilroyMedium.withSize(13)
        legend.horizontalAlignment = .center
        legend.xEntrySpace = 72
        legend.orientation = .horizontal
        legend.formToTextSpace = 6
    }

    func reloadChart(withAnimate: Bool) {
        let entries = buildEntriedFromData()
        let dataSet = buildDataSetFrom(entries: entries)
        let pieChartData = PieChartData(dataSet: dataSet)

        data = pieChartData

        let legendEntries = buildLegendEntries()
        legend.setCustom(entries: legendEntries)

        if withAnimate {
            animate(yAxisDuration: 1, easingOption: .easeOutCirc)
        }
    }

    // MARK: - Helpers

    func buildDataSetFrom(entries: [PieChartDataEntry]) -> PieChartDataSet {
        let dataSet = PieChartDataSet(entries: entries)
        dataSet.colors = [.Charts.orange, .Charts.red]
        dataSet.sliceSpace = 3
        dataSet.selectionShift = 0
        dataSet.drawValuesEnabled = false
        dataSet.label = nil
        dataSet.valueLineWidth = 3

        return dataSet
    }

    func buildEntriedFromData() -> [PieChartDataEntry] {
        var entries: [PieChartDataEntry] = []
        for (_, value) in chartData {
            let dataEntry = PieChartDataEntry(value: value)
            entries.append(dataEntry)
        }

        return entries
    }

    func buildLegendEntries() ->  [LegendEntry] {
        let percentTotal = chartData.reduce(0) { $0 + $1.value }

        let chartDataReversed = chartData.reversed()
        let legendEntries = chartDataReversed.map { categoryItem in
            let categoryPercent = Int(categoryItem.value / percentTotal * 100)
            let legendEntry = LegendEntry(label: "\(categoryItem.gender.title)  \(categoryPercent)%")
            legendEntry.form = .circle
            legendEntry.formSize = 10
            legendEntry.formColor = categoryItem.gender == .male ? .Charts.red : .Charts.orange
            legendEntry.labelColor = .black
            
            return legendEntry
        }

        return legendEntries
    }

}

