
import DGCharts
import UIKit
import StatisticBusinessLogic

final class StatisticAgeHorizontalBarChart: HorizontalBarChartView {

    typealias ChartItem = (
        ageRange: StatisticChartAgesRange,
        valueMale: Double,
        valueFemale: Double
    )

    // MARK: - Data

    private var chartData: [ChartItem] = []

    // MARK: - Init

    convenience init() {
        self.init(frame: .zero)
        setup()

        // TODO: удалить наполнение данных
        let data = [
            (StatisticChartAgesRange.from18to21, 100.0, 40.0),
            (StatisticChartAgesRange.from22to25, 10.0, 20.0),
            (StatisticChartAgesRange.from26to30, 30.0, 10.0),
            (StatisticChartAgesRange.from31to35, 1.0, 7.0),
            (StatisticChartAgesRange.from36to40, 0.0, 18.0),
            (StatisticChartAgesRange.from40to50, 7.0, 16.0),
            (StatisticChartAgesRange.over50, 9.0, 3.0),
        ]
        setDataAndReload(data: data, animate: false)
        ///
    }

    // MARK: - Update view (internal)

    func setDataAndReload(data: [ChartItem], animate: Bool) {
        chartData = data
        chartData.reverse()
        reloadChart(withAnimate: animate)
    }

}

private extension StatisticAgeHorizontalBarChart {

    // MARK: - Setup

    func setup() {
        scaleXEnabled = false
        scaleYEnabled = false
        setScaleEnabled(false)

        highlightPerTapEnabled = false
        highlightPerDragEnabled = false

        legend.enabled = false

        xAxis.enabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false

        leftAxis.axisMinimum = -13
        leftAxis.axisMaximum = 120
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false

        rightAxis.enabled = false

        extraTopOffset = 12
        extraBottomOffset = 21

        renderer = RoundedHorizontalBarChartRenderer(
            dataProvider: self,
            animator: chartAnimator,
            viewPortHandler: viewPortHandler
        )
    }

    // MARK: - Update view (private)

    func reloadChart(withAnimate: Bool) {
        let entriesByGroups = buildEntries()
        let dataSets = buildDataSetsFrom(entriesByGroups: entriesByGroups)

        let data = BarChartData(dataSets: dataSets)
        data.barWidth = 0.25
        data.groupBars(fromX: -0.75, groupSpace: 0.5, barSpace: 0.5)

        self.data = data

        setupXAxisLabels()

        if withAnimate {
            animate(yAxisDuration: 1, easingOption: .easeOutCirc)
        }
    }

    // MARK: - Helpers

    func buildEntries() -> [[BarChartDataEntry]] {
        var entriesMale: [BarChartDataEntry] = []
        var entriesFemale: [BarChartDataEntry] = []

        for (index, dataItem) in chartData.enumerated() {
            let indexMale = Double(index * 2)
            let indexFemale = Double(index * 2 + 1)

            let dataEntryMale = BarChartDataEntry(x: indexMale, y: dataItem.valueMale)
            let dataEntryFemale = BarChartDataEntry(x: indexFemale, y: dataItem.valueFemale)

            entriesMale.append(dataEntryMale)
            entriesFemale.append(dataEntryFemale)
        }

        return [entriesMale, entriesFemale]
    }

    func buildDataSetsFrom(entriesByGroups: [[BarChartDataEntry]]) -> [BarChartDataSet] {
        var dataSets: [BarChartDataSet] = []

        for (index, entries) in entriesByGroups.enumerated() {
            let dataSet = BarChartDataSet(entries: entries)
            dataSet.colors = [index == 0 ? UIColor.Charts.orange : UIColor.Charts.red]
            dataSet.drawValuesEnabled = true
            dataSet.valueTextColor = .black
            dataSet.valueFont = .gilroyMedium.withSize(10)
            dataSet.valueFormatter = PercentValueFormatter()

            dataSets.append(dataSet)
        }

        return dataSets
    }

    func setupXAxisLabels() {
        xAxis.granularity = 2
        xAxis.labelTextColor = .black
        xAxis.labelFont = .gilroySemiBold.withSize(15)
        xAxis.labelPosition = .bottom
        xAxis.xOffset = 2.5

        xAxis.labelCount = chartData.count * 2
        xAxis.axisMaximum = Double(chartData.count * 2) - 1

        let agesRanges = chartData.map { $0.ageRange }
        xAxis.valueFormatter = AgeRangesXAxisFormatter(agesRanges: agesRanges)
    }

}
