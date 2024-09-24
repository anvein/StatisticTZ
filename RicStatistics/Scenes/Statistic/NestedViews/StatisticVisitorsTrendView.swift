
import UIKit

final class StatisticVisitorsTrendView: UIView {


    // MARK: - Subviews

    private let titleLabel: UILabel = {
        $0.text = "Посетители" // TODO: lang
        $0.font = .gilroyBold.withSize(20)
        $0.textColor = .black
        return $0
    }(UILabel())

    private let contentContainer: UIView = {
        $0.backgroundColor = .white
        $0.cornerRadius = 16
        return $0
    }(UIView())

    private let trendView: StatisticCommonTrendView = {
        $0.count = "-"
        $0.text = "Количество посетителей в этом месяце неизвестно"
        return $0
    }(StatisticCommonTrendView())

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

    func fillVisitorsTrend(
        visitorsCountsByMonths: [Int],
        count: String,
        trendType: StatisticCommonTrendView.TrendType,
        text: String
    ) {
        trendView.setChartData(countsByPeriods: visitorsCountsByMonths)
        trendView.count = count
        trendView.trendType = trendType
        trendView.text = text
    }

}

private extension StatisticVisitorsTrendView {

    // MARK: - Setup

    func setup() {
        addSubviews(titleLabel, contentContainer)
        contentContainer.addSubviews(trendView)
    }

    func calculateFramesOfSubviews() {
        titleLabel.pin
            .top()
            .horizontally()
            .sizeToFit(.width)
        contentContainer.pin
            .below(of: titleLabel)
            .marginTop(12)
            .horizontally()

        trendView.pin
            .top(19)
            .start(7)
            .end(20)
        trendView.layoutIfNeeded()

        contentContainer.pin.height(trendView.frame.maxY + 17)
        self.pin.wrapContent(.vertically)
    }

}


