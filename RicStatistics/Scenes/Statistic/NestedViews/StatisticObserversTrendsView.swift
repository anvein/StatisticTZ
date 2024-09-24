import UIKit

final class StatisticObserversTrendsView: UIView {

    // MARK: - Subviews

    private let titleLabel: UILabel = {
        $0.text = "Наблюдатели" // TODO: lang
        $0.font = .gilroyBold.withSize(20)
        $0.textColor = .Common.screenSectionTitle
        return $0
    }(UILabel())

    private let containerView: UIView = {
        $0.backgroundColor = .Common.screenSectionBg
        $0.cornerRadius = 16
        return $0
    }(UIView())

    private let newObserversView: StatisticCommonTrendView = {
        $0.trendType = .up
        $0.count = "-"
        $0.text = "Новые наблюдатели в этом месяце" // TODO: lang
        return $0
    }(StatisticCommonTrendView())

    private let separatorView: UIView = {
        $0.backgroundColor = .Common.separator
        return $0
    }(UIView())

    private let lostObserversView: StatisticCommonTrendView = {
        $0.trendType = .down
        $0.count = "-"
        $0.text = "Пользователей перестали за Вами наблюдать" // TODO: lang
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

    func fillNewObserversTrendView(countsByMonths: [Int], count: String) {
        newObserversView.setChartData(countsByPeriods: countsByMonths)
        newObserversView.count = count
    }

    func fillLostObserversTrendView(countsByMonths: [Int], count: String) {
        lostObserversView.setChartData(countsByPeriods: countsByMonths)
        lostObserversView.count = count
    }

}

private extension StatisticObserversTrendsView {

    // MARK: - Setup

    func setup() {
        addSubviews(titleLabel, containerView)
        containerView.addSubviews(newObserversView, separatorView, lostObserversView)
    }

    func calculateFramesOfSubviews() {
        titleLabel.pin
            .top()
            .horizontally()
            .sizeToFit(.width)

        containerView.pin
            .below(of: titleLabel)
            .marginTop(12)
            .horizontally()

        newObserversView.pin
            .top(19)
            .horizontally(20)
        newObserversView.layoutIfNeeded()

        separatorView.pin
            .below(of: newObserversView)
            .marginTop(17)
            .height(0.5)
            .horizontally()

        lostObserversView.pin
            .below(of: separatorView)
            .marginTop(18)
            .horizontally(20)
        lostObserversView.layoutIfNeeded()

        containerView.pin.height(lostObserversView.frame.maxY + 22)
        self.pin.wrapContent(.vertically)
    }

}

