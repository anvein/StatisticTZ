
import UIKit
import RxSwift
import DGCharts
import StatisticBusinessLogic

final class StatisticVisitorsByPeriodView: UIView {

    // MARK: - Data / State

    private var periodsArray: [VisitorsStatisticPeriod] = []

    private let disSelectPeriodSubject = BehaviorSubject<VisitorsStatisticPeriod?>(value: nil)
    var disSelectPeriodObservable: Observable<VisitorsStatisticPeriod?> {
        return disSelectPeriodSubject.asObservable()
    }

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

    // MARK: - Update view

    func setMenuPeriods(_ periods: [VisitorsStatisticPeriod]) {
        periodsArray = periods
        periodsMenuCollectionView.reloadData()
    }

    func selectMenuItem(with period: VisitorsStatisticPeriod) {
        guard let indexPath = getIndexPath(for: period) else { return }

        periodsMenuCollectionView.selectItem(
            at: indexPath,
            animated: false,
            scrollPosition: .centeredHorizontally
        )
    }

    func setChartDataAndReload(data: [StatisticByPeriodLineChart.ChartDataItem], animate: Bool) {
        chartView.setDataAndReload(data: data, animate: animate)
    }
}

private extension StatisticVisitorsByPeriodView {

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

    func getIndexPath(for menuItem: VisitorsStatisticPeriod) -> IndexPath? {
        guard let index = periodsArray.firstIndex(of: menuItem) else { return nil }
        return IndexPath(row: index, section: 0)
    }
}

// MARK: - UICollectionViewDataSource

extension StatisticVisitorsByPeriodView: UICollectionViewDataSource {
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

extension StatisticVisitorsByPeriodView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath),
              cell.isSelected { return false }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let period = getMenuItemFor(indexPath: indexPath)
        guard let period, period != .byDay else {
            disSelectPeriodSubject.onNext(period)
            return
        }

        // TODO: удалить временное наполнение данных
        ///////////////////////////////////////////////////////////////////////////
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dates = ["2024-03-05", "2024-03-06", "2024-03-07", "2024-03-08", "2024-03-09", "2024-03-10", "2024-03-11"].compactMap({
            return dateFormatter.date(from: $0)
        })

        var chartData = [StatisticByPeriodLineChart.ChartDataItem]()
        for date in dates {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM"
            let labelText = dateFormatter.string(from: date)

            dateFormatter.dateFormat = "d MMMM"
            dateFormatter.locale = .init(identifier: "ru_RU")
            let tooltipText = dateFormatter.string(from: date)

            chartData.append((
                value: Int.random(in: 0...55),
                xAxisText: labelText,
                toolTipText: tooltipText
            ))
        }

        chartView.setDataAndReload(data: chartData, animate: true)
        ///////////////////////////////////////////////////////////////////////////
    }
}
