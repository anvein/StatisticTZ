
import UIKit
import Foundation
import DGCharts

class StatisticByPeriodLineChartTooltipView: MarkerView {

    var dates = [Date]()

    // MARK: - Subviews

    private let textLabel: UILabel = {
        $0.textColor = .Charts.red
        $0.font = .gilroySemiBold.withSize(15)
        $0.setKern(-0.1)
        return $0
    }(UILabel())

    private let dateLabel: UILabel = {
        $0.textColor = .textGray
        $0.font = .gilroyMedium.withSize(13)
        $0.setKern(-0.05)
        return $0
    }(UILabel())

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()

        textLabel.pin
            .top()
            .start()
            .sizeToFit()

        dateLabel.pin
            .top(to: textLabel.edge.bottom)
            .marginTop(8)
            .start()
            .sizeToFit()

        self.pin.wrapContent(padding: 16)
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let number = Int(entry.y)
        let numberPluralyze = number.pluralize(forms: ("посетитель", "посетителя", "посетителей"))
        textLabel.text = "\(number) \(numberPluralyze)"

        if let date = dates[safe: Int(entry.x)] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM"
            dateFormatter.locale = .init(identifier: "ru_RU")
            dateLabel.text = dateFormatter.string(from: date)
        }

        setNeedsLayout()
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        return CGPoint(
            x: -self.frame.width / 2,
            y: -self.frame.height - 15
        )
    }

    // MARK: - Setup

    private func setupView() {
        addSubviews(textLabel, dateLabel)

        backgroundColor = .white
        cornerRadius = 12
        borderWidth = 1
        borderColor = .Charts.shadowLine
    }

}
