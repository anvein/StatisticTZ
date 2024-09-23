
import Foundation
import UIKit
import DGCharts

final class StatisticByPeriodLineChart: LineChartView {

    typealias ChartDataItem = (value: Int, date: Date)

    // MARK: - Data

    private var chartData: [ChartDataItem] = []

    // MARK: - Additional views

    private let tooltipChart = StatisticByPeriodLineChartTooltipView(
        frame: .init(x: 0, y: 0, width: 128, height: 72)
    )

    // MARK: - Init

    convenience init() {
        self.init(frame: .zero)
        setup()

        // TODO: временная генерация данных
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let values = [0, 3, 5, 2, 1, 15, 2]
        let dates = ["2024-03-05", "2024-03-06", "2024-03-07", "2024-03-08", "2024-03-09", "2024-03-10", "2024-03-11"].compactMap({
            return dateFormatter.date(from: $0)
        })

        var chartData = [ChartDataItem]()
        for (value, date) in zip(values, dates) {
            chartData.append((value: value, date: date))
        }

        setDataAndReload(data:chartData, animate: false)
        ///
    }

    // MARK: - Update view (internal)

    func setDataAndReload(data: [ChartDataItem], animate: Bool) {
        chartData = data
        reloadChart(withAnimate: animate)
    }

}

private extension StatisticByPeriodLineChart {

    // MARK: - Setup

    func setup() {
        backgroundColor = .Common.screenSectionBg
        cornerRadius = 16

        setScaleEnabled(false)

        chartDescription.enabled = false
        legend.enabled = false

        xAxis.labelPosition = .bottom
        xAxis.labelFont = .gilroyMedium.withSize(11)
        xAxis.labelTextColor = .textGray
        xAxis.drawGridLinesEnabled = false

        xAxis.axisLineDashLengths = [7, 5]
        xAxis.axisLineColor = .Charts.linesGray
        xAxis.axisLineWidth = 1
        xAxis.yOffset = 11

        xAxis.spaceMin = 1
        xAxis.spaceMax = 1

        leftAxis.drawLabelsEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        rightAxis.enabled = false

        setExtraOffsets(left: 14, top: 29, right: 14, bottom: 10)

        dragYEnabled = false
        dragXEnabled = true

        tooltipChart.chartView = self
        marker = tooltipChart
    }

    // MARK: - Update view (private)


    func reloadChart(withAnimate: Bool) {
        setupMinMaxChartsAndLimitLines()

        let entries = buildLineEntries()
        let lineDataSet = buildLineDataSetFrom(entries)

        let data = LineChartData()
        data.dataSets = [lineDataSet]

        self.data = data

        setupXAxisLabels()
        setupToolTip()

        if withAnimate {
            animate(yAxisDuration: 0.8, easingOption: .easeOutCirc)
        }
    }

    // MARK: - Helpers

    func setupMinMaxChartsAndLimitLines() {
        leftAxis.removeAllLimitLines()

        let values = chartData.map { $0.value }

        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 100
        let delta = Double(maxValue - minValue)

        leftAxis.axisMaximum = Double(maxValue) + delta
        leftAxis.axisMinimum = Double(minValue) - delta * 0.3

        let finalDelta = leftAxis.axisMaximum - leftAxis.axisMinimum

        let topLimitLine = ChartLimitLine(limit: leftAxis.axisMaximum)
        let center = leftAxis.axisMaximum - finalDelta / 2
        let centerLimitLine = ChartLimitLine(limit: center)

        [topLimitLine, centerLimitLine].forEach { [weak self] limitLine in
            limitLine.lineWidth = 1
            limitLine.lineColor = .Charts.linesGray
            limitLine.lineDashLengths = [7, 7]
            self?.leftAxis.addLimitLine(limitLine)
        }
    }

    func buildLineEntries() -> [ChartDataEntry] {
        var chartEntry = [ChartDataEntry]()
        for (index, chartDataItem) in chartData.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(index), y: Double(chartDataItem.value))
            chartEntry.append(dataEntry)
        }

        return chartEntry
    }

    func buildLineDataSetFrom(_ entries: [ChartDataEntry]) -> LineChartDataSet {
        let line = LineChartDataSet(entries: entries)
        line.colors = [UIColor.Charts.red]
        line.circleColors = [UIColor.Charts.red]
        line.circleRadius = 5.5
        line.circleHoleRadius = 2.75
        line.drawValuesEnabled = false
        line.lineWidth = 3
        line.mode = .linear

        line.highlightEnabled = true
        line.highlightColor = .Charts.red
        line.highlightLineWidth = 1
        line.drawHorizontalHighlightIndicatorEnabled = false
        line.highlightLineDashLengths = [7, 5]

        return line
    }

    func setupXAxisLabels() {
        let dates = chartData.map { $0.date }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        xAxis.valueFormatter = DatesXAxisFormatter(
            dates: dates,
            dateFormatter: dateFormatter
        )
    }

    func setupToolTip() {
        let dates = chartData.map { $0.date }
        tooltipChart.dates = dates
    }

}
