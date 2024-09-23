
import UIKit

final class TopVisitorTableViewCell: UITableViewCell {

    // MARK: - Subviews

    private let avatarImageView: UIImageView = {
        $0.backgroundColor = .lightGray
        return $0
    }(UIImageView())

    private let titleLabel: UILabel = {
        $0.font = .gilroySemiBold.withSize(15)
        $0.textColor = .black
        $0.setKern(-0.1)
        return $0
    }(UILabel())

    private let isOnlineView: UIView = {
        $0.backgroundColor = .OnlineStatus.background
        $0.borderColor = .OnlineStatus.border
        $0.borderWidth = 1
        return $0
    }(UIView())

    private let disclosureImageView: UIImageView = {
        $0.image = .tableCellDisclosureRight
        $0.contentMode = .center
        return $0
    }(UIImageView())

    private let bottomSeparator: UIView = {
        $0.backgroundColor = .TopVisitorsCell.separator
        return $0
    }(UIView())

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        calculateSubviewsFrames()
    }

    // MARK: - Update view

    func fillFrom(user: TopVisitorUserModel) {
        titleLabel.text = "\(user.username), \(user.age)"
        isOnlineView.isHidden = !user.isOnline
    }

    func setIsLast(_ isLast: Bool) {
        bottomSeparator.isHidden = isLast
    }

}

private extension TopVisitorTableViewCell {

    // MARK: - Setup

    func setup() {
        selectionStyle = .none
        backgroundColor = .white

        contentView.addSubviews(
            avatarImageView,
            isOnlineView,
            titleLabel,
            disclosureImageView,
            bottomSeparator
        )
    }

    func calculateSubviewsFrames() {
        avatarImageView.pin
            .start()
            .marginStart(16)
            .vCenter()
            .size(38)
        isOnlineView.pin
            .size(10)
            .end(to: avatarImageView.edge.end)
            .bottom(to: avatarImageView.edge.bottom)
        disclosureImageView.pin
            .size(24)
            .end(16)
            .vCenter()
        titleLabel.pin
            .start(to: avatarImageView.edge.end)
            .marginStart(12)
            .end(to: disclosureImageView.edge.start)
            .marginEnd(16)
            .vCenter(1)
            .sizeToFit(.width)

        bottomSeparator.pin
            .height(0.5)
            .start(66)
            .end(1)
            .bottom()

        avatarImageView.cornerRadius = avatarImageView.bounds.height / 2
        isOnlineView.cornerRadius = isOnlineView.frame.height / 2
    }
}

// MARK: - HighlightableCell

extension TopVisitorTableViewCell: HighlightableCell {
    func setCellHighlighted(_ highlighted: Bool) {
        Self.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction]) { [weak self] in
            self?.backgroundColor = highlighted ? .TopVisitorsCell.highlightedBg : .white
        }
    }
}
