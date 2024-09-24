
import UIKit
import DGCharts

final class StatisticLineSimpleTrendChartView: LineChartView {

    // MARK: - Data

    private var chartData: [Int] = []

    // MARK: - Init

    convenience init() {
        self.init(frame: .zero)
        setup()
    }

    // MARK: - Update view (internal)

    func setDataAndReload(data: [Int]) {
        chartData = data
        reloadChart()
    }

}

private extension StatisticLineSimpleTrendChartView {

    // MARK: - Setup

    func setup() {
        noDataText = "Нет данных"
        noDataFont = .gilroyMedium.withSize(12)

        setScaleEnabled(false)
        chartDescription.enabled = false
        legend.enabled = false
        highlightPerDragEnabled = false
        highlightPerTapEnabled = false

        leftAxis.drawGridLinesEnabled = false
        rightAxis.drawGridLinesEnabled = false
        xAxis.drawGridLinesEnabled = false

        xAxis.spaceMin = 0.2
        xAxis.spaceMax = 0.2

        xAxis.enabled = false
        leftAxis.enabled = false
        rightAxis.enabled = false
    }

    func reloadChart() {
        let entries = buildChartDataEntry()
        let trendType = calculateTrendType()

        let shadowLineDataSet = buildShadowLineDataSetFrom(entries)
        let mainLineDataSet = buildMainLineDataSetFrom(entries, trendType: trendType)

        let lastPointEntries = buildLastPointLineDataEntry()
        let lastPointLineDataSet = buildLastPointLineDataSetFrom(lastPointEntries, trendType: trendType)

        let data = LineChartData()
        data.dataSets = [shadowLineDataSet, mainLineDataSet, lastPointLineDataSet]

        self.data = data
    }

    // MARK: - Helpers

    func buildChartDataEntry() -> [ChartDataEntry] {
        var visitorsChartEntry = [ChartDataEntry]()
        for (index, value) in chartData.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(index), y: Double(value))
            visitorsChartEntry.append(dataEntry)
        }

        return visitorsChartEntry
    }

    func buildLastPointLineDataEntry() -> [ChartDataEntry] {
        var lastPointChartEntry = [ChartDataEntry]()
        if let lastPoint = chartData.last {
            let lastPointEntry = ChartDataEntry(x: Double(chartData.count - 1), y: Double(lastPoint))
            lastPointChartEntry.append(lastPointEntry)
        }

        return lastPointChartEntry
    }

    func calculateTrendType() -> StatisticChartTrendType {
        var trendType: StatisticChartTrendType = .up
        if let currentValue = chartData.last,
           let previousValue = chartData[safe: chartData.count - 2] {
            trendType = currentValue > previousValue ? .up : .down
        }

        return trendType
    }

    func buildShadowLineDataSetFrom(_ entries: [ChartDataEntry]) -> LineChartDataSet {
        let lineDataSet = LineChartDataSet(entries: entries)
        lineDataSet.colors = [.Charts.shadowLine]
        lineDataSet.drawCirclesEnabled = false
        lineDataSet.drawValuesEnabled = false
        lineDataSet.lineWidth = 3
        lineDataSet.mode = .horizontalBezier

        lineDataSet.drawHorizontalHighlightIndicatorEnabled = false

        return lineDataSet
    }

    func buildMainLineDataSetFrom(
        _ entries: [ChartDataEntry],
        trendType: StatisticChartTrendType
    ) -> LineChartDataSet {
        let lineDataSet = LineChartDataSet(entries: entries)

        lineDataSet.colors = [trendType.color]
        lineDataSet.drawCirclesEnabled = false
        lineDataSet.drawValuesEnabled = false
        lineDataSet.lineWidth = 3
        lineDataSet.mode = .cubicBezier
        lineDataSet.cubicIntensity = 0.25
        lineDataSet.lineCapType = .round
        lineDataSet.drawHorizontalHighlightIndicatorEnabled = false

        return lineDataSet
    }

    func buildLastPointLineDataSetFrom(
        _ entries: [ChartDataEntry],
        trendType: StatisticChartTrendType
    ) -> LineChartDataSet {
        let lineDataSet = LineChartDataSet(entries: entries)
        lineDataSet.drawValuesEnabled = false
        lineDataSet.circleColors = [trendType.color]
        lineDataSet.circleRadius = 5.5
        lineDataSet.circleHoleRadius = 2.75

        return lineDataSet
    }

}
