
import UIKit
import PinLayout
import StatisticBusinessLogic

final class HorizontalMenuButtonCollectionViewCell: UICollectionViewCell {

    // MARK: - Subviews

    private lazy var titleLabel: UILabel = {
        $0.font = .gilroySemiBold.withSize(15)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.setKern(-0.1)
        return $0
    }(UILabel())

    // MARK: - Overriden properties

    override var isSelected: Bool {
        didSet {
            Self.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction]) { [weak self] in
                guard let self = self else { return }
                self.updateAppearanceFor(isSelected: self.isSelected)
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            Self.animate(withDuration: 0.15, delay: 0, options: [.curveLinear, .allowUserInteraction]) { [weak self] in
                guard let self = self else { return }
                self.updateAppearanceFor(isHighlighted: self.isHighlighted)
            }
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutIfNeeded()
        layoutAttributes.frame.size.width = contentView.frame.width

        return layoutAttributes
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let horizontalInset: CGFloat = 16
        titleLabel.pin.horizontally(horizontalInset).vCenter(0.75).sizeToFit()
        contentView.pin.width(titleLabel.frame.maxX + horizontalInset)

        cornerRadius = frame.height / 2
    }

    // MARK: - Update view

    func fill(with period: StatisticPeriod) {
        titleLabel.text = period.title
        setNeedsLayout()
    }
}

private extension HorizontalMenuButtonCollectionViewCell {
    // MARK: - Setup

    func setup() {
        contentView.addSubviews(titleLabel)

        borderWidth = 1
        updateAppearanceFor(isSelected: isSelected)
    }

    func updateAppearanceFor(isSelected: Bool, isHighlighted: Bool = false) {
        if isSelected {
            let bgColor: UIColor = isHighlighted ? .horizontalMenuCellSelectedBg.withAlphaComponent(0.8) : .horizontalMenuCellSelectedBg
            backgroundColor = bgColor
            borderColor = bgColor
            titleLabel.textColor = .white
        } else {
            backgroundColor = isHighlighted ? .horizontalMenuCellBorder : .horizontalMenuCellBg
            borderColor = .horizontalMenuCellBorder
            titleLabel.textColor = .black
        }
    }

    func updateAppearanceFor(isHighlighted: Bool) {
        guard !isSelected else { return }
        transform = isHighlighted ? transform.scaledBy(x: 0.95, y: 0.95) : .identity
    }

}
