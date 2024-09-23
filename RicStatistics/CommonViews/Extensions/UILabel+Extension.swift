
import UIKit

extension UILabel {
    func setLineHeight(_ lineHeight: Float) {
        let attributedText = self.attributedText ?? NSAttributedString(string: self.text ?? " ")
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = CGFloat(lineHeight)
        paragraphStyle.maximumLineHeight = CGFloat(lineHeight)

        mutableAttributedText.addAttributes(
            [.paragraphStyle: paragraphStyle],
            range: NSRange(location: 0, length: mutableAttributedText.length)
        )

        self.attributedText = mutableAttributedText
    }


    func setKern(_ kern: Float) {
        let attributedText = self.attributedText ?? NSAttributedString(string: self.text ?? " ")
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)

        mutableAttributedText.addAttributes(
            [.kern: NSNumber(floatLiteral: Double(kern))],
            range: NSRange(location: 0, length: mutableAttributedText.length)
        )

        self.attributedText = mutableAttributedText
    }
}
