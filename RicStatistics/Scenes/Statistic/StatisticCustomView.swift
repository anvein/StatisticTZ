
import UIKit
import PinLayout

final class StatisticCustomView: UIView {

    // MARK: - Subviews

    lazy var refreshControl: UIRefreshControl = {
        return $0
    }(UIRefreshControl())

    private lazy var scrollView: UIScrollView = {
        $0.showsVerticalScrollIndicator = false
        $0.delaysContentTouches = false
        $0.refreshControl = refreshControl
        $0.refreshControl?.bounds.origin.y = ($0.refreshControl?.bounds.origin.y ?? 0) - 25
        if #available(iOS 17.4, *) {
            $0.bouncesVertically = true
        } else {
            $0.alwaysBounceVertical = true
        }

        return $0
    }(UIScrollView())

    private let contentContainerView: UIView = .init()

    private let titleLabel: UILabel = {
        $0.text = "Статистика"
        $0.textColor = .black
        $0.font = .gilroyBold.withSize(32)
        $0.numberOfLines = 0
        $0.setKern(-0.1)
        return $0
    }(UILabel())

    let visitorsTrendView: StatisticVisitorsTrendView = .init()
    let visitorsByPeriodView: StatisticVisitorsByPeriodView = .init()
    let topVisitorsProfilesView: StatisticTopVisitorsProfilesView = .init()
    private let byGenderAndAgeView: StatisticByGenderAndAgeView = .init()
    let observersTrendsView: StatisticObserversTrendsView = .init()

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

    func setIsLoadingRefreshControl(_ isLoading: Bool) {
        if isLoading {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
}

private extension StatisticCustomView {

    // MARK: - Setup (private)

    func setup() {
        backgroundColor = .mainBackground

        addSubviews(scrollView)
        scrollView.addSubview(contentContainerView)
        contentContainerView.addSubviews(
            titleLabel,
            visitorsTrendView,
            visitorsByPeriodView,
            topVisitorsProfilesView,
            byGenderAndAgeView,
            observersTrendsView
        )
    }

    func calculateFramesOfSubviews() {
        scrollView.pin
            .top(pin.safeArea)
            .horizontally()
            .bottom()
        contentContainerView.pin.width(scrollView.bounds.width)

        titleLabel.pin
            .top()
            .horizontally(16)
            .sizeToFit(.width)

        visitorsTrendView.pin
            .below(of: titleLabel)
            .marginTop(38)
            .horizontally(16)

        visitorsByPeriodView.pin
            .below(of: visitorsTrendView)
            .marginTop(28)
            .horizontally()

        topVisitorsProfilesView.pin
            .below(of: visitorsByPeriodView)
            .marginTop(32)
            .horizontally(16)

        byGenderAndAgeView.pin
            .below(of: topVisitorsProfilesView)
            .marginTop(32)
            .horizontally()

        observersTrendsView.pin
            .below(of: byGenderAndAgeView)
            .marginTop(32)
            .horizontally(16)

        contentContainerView.pin.wrapContent(.vertically, padding: .init(top: 48, left: 0, bottom: 32, right: 0))
        scrollView.contentSize = contentContainerView.frame.size
    }

}
