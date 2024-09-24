
import UIKit

final class StatisticByGenderAndAgeView: UIView {

    // MARK: - Model

    private let periodsArray: [StatisticByGenderAndAgePeriod] = StatisticByGenderAndAgePeriod.allCases

    // MARK: - Subviews

    private let titleLabel: UILabel = {
        $0.text = "Пол и возраст" // TODO: lang
        $0.font = .gilroyBold.withSize(20)
        $0.setKern(-0.1)
        $0.textColor = .black
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    private lazy var periodsMenuCollectionView: HorizontalMenuCollectionView = {
        $0.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        $0.delegate = self
        $0.dataSource = self
        $0.allowsSelection = true
        return $0
    }(HorizontalMenuCollectionView())

    private let chartsContainerView: UIView = {
        $0.backgroundColor = .white
        $0.cornerRadius = 16
        return $0
    }(UIView())

    private let genderPieChartView: StatisticGenderPieChartView = {
        
        return $0
    }(StatisticGenderPieChartView())

    private let chartsSeparatorView: UIView = {
        $0.backgroundColor = .Common.separator
        return $0
    }(UIView())

    private let agesChartView: StatisticAgeHorizontalBarChart = .init()

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

private extension StatisticByGenderAndAgeView {

    // MARK: - Setup

    func setup() {
        addSubviews(titleLabel, periodsMenuCollectionView, chartsContainerView)
        chartsContainerView.addSubviews(
            genderPieChartView,
            chartsSeparatorView,
            agesChartView
        )
    }

    func calculateFramesOfSubviews() {
        titleLabel.pin
            .top()
            .horizontally(16)
            .sizeToFit(.width)

        periodsMenuCollectionView.pin
            .below(of: titleLabel)
            .marginTop(12)
            .horizontally()
            .height(32)

        chartsContainerView.pin
            .below(of: periodsMenuCollectionView)
            .marginTop(12)
            .horizontally(16)

        genderPieChartView.pin
            .top(28)
            .horizontally(16)
            .height(184)

        chartsSeparatorView.pin
            .below(of: genderPieChartView)
            .marginTop(16)
            .horizontally()
            .height(0.5)

        agesChartView.pin
            .below(of: chartsSeparatorView)
            .horizontally(16)
            .height(300)

        chartsContainerView.pin.height(agesChartView.frame.maxY)
        self.pin.wrapContent()
    }

    // MARK: - Helpers

    func getMenuItemFor(indexPath: IndexPath) -> StatisticByGenderAndAgePeriod? {
        return periodsArray[safe: indexPath.item]
    }
}

// MARK: - UICollectionViewDataSource

extension StatisticByGenderAndAgeView: UICollectionViewDataSource {
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

extension StatisticByGenderAndAgeView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath),
              cell.isSelected { return false }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: перезагрузить график

        genderPieChartView.setDataAndReload(data: [(.female, Double.random(in: 30...50)), (.male, 40)], animate: true)


        // TODO: удалить наполнение данных

        let data = StatisticChartAgesRange.allCases.map { agesRange in
            return (agesRange, Double.random(in: 0...100), Double.random(in: 0...100))
        }

        agesChartView.setDataAndReload(data: data, animate: true)
        ///
    }
}
