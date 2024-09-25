
import UIKit
import DGCharts

final class StatisticCommonTrendView: UIView {

    typealias ChartParams = (
        countByPeriods: [Int],
        trendType: StatisticLineSimpleTrendChartView.TrendType
    )

    // MARK: - Subviews accessors

    var chartParams: ChartParams? = nil {
        didSet {
            guard let chartParams else { return }
            chartView.setDataAndReload(
                data: chartParams.countByPeriods,
                trendType: chartParams.trendType
            )
        }
    }

    var count: String? {
        get { countLabel.text }
        set {
            countLabel.text = newValue
            countLabel.pin.sizeToFit(.widthFlexible)
        }
    }

    var trendType: TrendType = .flat {
        didSet {
            switch trendType {
            case .up:
                arrowImageView.image = .arrowUpGreen
            case .down:
                arrowImageView.image = .arrowDownRed
            case .flat:
                arrowImageView.image = nil
            }
        }
    }

    var text: String? {
        get { textLabel.text }
        set {
            textLabel.text = newValue
            textLabel.pin.sizeToFit(.width)
        }
    }

    // MARK: - Subviews

    private let chartView: StatisticLineSimpleTrendChartView = .init()

    private let countLabel: UILabel = {
        $0.font = .gilroyBold.withSize(20)
        $0.textColor = .black
        $0.numberOfLines = 1
        $0.setKern(-0.1)
        return $0
    }(UILabel())

    private let arrowImageView: UIImageView = .init()

    private let textLabel: UILabel = {
        $0.font = .gilroyMedium.withSize(15)
        $0.textColor = .textGray
        $0.numberOfLines = 0
        $0.setLineHeight(17)
        return $0
    }(UILabel())

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

private extension StatisticCommonTrendView {

    // MARK: - Setup

    func setup() {
        addSubviews(chartView, countLabel, arrowImageView, textLabel)
    }

    func calculateFramesOfSubviews() {
        chartView.pin
            .size(.init(width: 118, height: 56))
            .start()
            .top()

        countLabel.pin
            .top()
            .start(to: chartView.edge.end)
            .marginStart(10)
            .sizeToFit()
        arrowImageView.pin
            .start(to: countLabel.edge.end)
            .marginStart(7)
            .end()
            .vCenter(to: countLabel.edge.vCenter)
            .marginTop(-1)
            .size(.init(width: 9, height: 14))
        textLabel.pin
            .top(to: countLabel.edge.bottom)
            .marginTop(8)
            .start(to: countLabel.edge.left)
            .end()
            .sizeToFit(.width)

        self.pin.height(textLabel.frame.maxY)
    }

}
