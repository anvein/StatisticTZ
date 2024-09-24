
import UIKit
import DGCharts

final class StatisticByPeriodView: UIView {

    // MARK: - Model

    private let periodsArray: [VisitorsStatisticPeriod] = VisitorsStatisticPeriod.allCases

    // MARK: - Subviews

    private lazy var periodsMenuCollectionView: HorizontalMenuCollectionView = {
        $0.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        $0.delegate = self
        $0.dataSource = self
        $0.allowsSelection = true
        return $0
    }(HorizontalMenuCollectionView())

    private lazy var chartView: StatisticByPeriodLineChart = .init()
    
    // MARK: - Init

    convenience init() {
        self.init(frame: .zero)
        setup()
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        calculateFramesOfSubviews()
    }


}

private extension StatisticByPeriodView {

    // MARK: - Setup

    func setup() {
        addSubviews(periodsMenuCollectionView, chartView)
    }

    func calculateFramesOfSubviews() {
        periodsMenuCollectionView.pin
            .top()
            .horizontally()
            .height(32)

        chartView.pin
            .below(of: periodsMenuCollectionView)
            .marginTop(12)
            .horizontally(16)
            .height(208)

        self.pin.wrapContent(.vertically)
    }

    // MARK: - Helpers

    func getMenuItemFor(indexPath: IndexPath) -> VisitorsStatisticPeriod? {
        return periodsArray[safe: indexPath.item]
    }
}

// MARK: - UICollectionViewDataSource

extension StatisticByPeriodView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return periodsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let period = getMenuItemFor(indexPath: indexPath),
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HorizontalMenuButtonCollectionViewCell.className,
                for: indexPath
              ) as? HorizontalMenuButtonCollectionViewCell else { return UICollectionViewCell() }

        cell.fill(with: period)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension StatisticByPeriodView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath),
              cell.isSelected { return false }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: перезагрузить график
        ///
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var values: [Int] = []
        for _ in 0...6 {
            values.append(Int.random(in: 0...55))
        }

        let dates = ["2024-03-05", "2024-03-06", "2024-03-07", "2024-03-08", "2024-03-09", "2024-03-10", "2024-03-11"].compactMap({
            return dateFormatter.date(from: $0)
        })

        var chartData = [StatisticByPeriodLineChart.ChartDataItem]()
        for (value, date) in zip(values, dates) {
            chartData.append((value: value, date: date))
        }

        chartView.setDataAndReload(data: chartData, animate: true)
        ///
    }
}
