
import DGCharts
import Foundation
import CoreGraphics
import UIKit

class RoundedHorizontalBarChartRenderer: BarChartRenderer {

    override func drawDataSet(context: CGContext, dataSet: BarChartDataSetProtocol, index: Int) {
        guard let dataProvider = dataProvider,
              let barData = dataProvider.barData else { return }

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        let phaseY = animator.phaseY
        let barWidthHalf = barData.barWidth / 2.0

        for i in 0 ..< Int(ceil(Double(dataSet.entryCount) * animator.phaseX)) {
            guard let entry = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }

            let left = min(entry.y * phaseY, 0)
            let right = max(entry.y * phaseY, 0)
            let top = entry.x + barWidthHalf
            let bottom = entry.x - barWidthHalf

            let topPt = trans.pixelForValues(x: 0, y: top)
            let bottomPt = trans.pixelForValues(x: 0, y: bottom)
            let leftPt = trans.pixelForValues(x: left, y: entry.x)
            let rightPt = trans.pixelForValues(x: right, y: entry.x)

            let height = bottomPt.y - topPt.y
            var width = rightPt.x - leftPt.x
            width = (width == 0) ? height : width + height

            let barRect = CGRect(
                x: leftPt.x,
                y: bottomPt.y,
                width: width,
                height: height
            )

            let radius = min(barRect.width, barRect.height) / 2.0
            let path: UIBezierPath = UIBezierPath(roundedRect: barRect, cornerRadius: radius)

            context.setFillColor(dataSet.color(atIndex: i).cgColor)
            context.addPath(path.cgPath)
            context.fillPath()

            if dataSet.isDrawValuesEnabled {
                let valueText = dataSet.valueFormatter.stringForValue(entry.y, entry: entry, dataSetIndex: index, viewPortHandler: viewPortHandler)
                let valueFont = dataSet.valueFont
                let valueTextColor = dataSet.valueTextColor

                // Теперь вызов метода с правильными параметрами
                drawValue(
                    context: context,
                    value: valueText,
                    xPos: rightPt.x + 10 + height,
                    yPos: (topPt.y + bottomPt.y) / 2,
                    font: valueFont,
                    align: .left,
                    color: valueTextColor,
                    anchor: CGPoint(x: 0, y: 0),
                    angleRadians: 0 
                )
            }
        }
    }
}
