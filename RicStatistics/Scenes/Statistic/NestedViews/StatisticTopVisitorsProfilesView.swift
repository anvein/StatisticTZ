
import UIKit
import PinLayout

final class StatisticTopVisitorsProfilesView: UIView {

    // MARK: - Settings

    private static let maxUsersInTable = 3

    // MARK: - Data

    private var topVisitorsArray: [TopVisitorModelDto] = []

    // MARK: - Subviews

    private let titleLabel: UILabel = {
        $0.text = "Чаще всех посещают Ваш профиль" 
        $0.font = .gilroyBold.withSize(20)
        $0.setKern(-0.1)
        $0.textColor = .black
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    private lazy var usersTableView: UITableView = {
        $0.separatorStyle = .none
        $0.cornerRadius = 14
        $0.rowHeight = 62
        $0.delaysContentTouches = false
        $0.register(TopVisitorTableViewCell.self, forCellReuseIdentifier: TopVisitorTableViewCell.className)
        $0.dataSource = self
        $0.delegate = self
        return $0
    }(UITableView())

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

    func reloadTableWithData(_ topVisitorsArray: [TopVisitorModelDto]) {
        self.topVisitorsArray = topVisitorsArray
        usersTableView.reloadData()
    }

}

private extension StatisticTopVisitorsProfilesView {

    // MARK: - Setup

    func setup() {
        addSubviews(titleLabel, usersTableView)
    }

    func calculateFramesOfSubviews() {
        titleLabel.pin
            .top()
            .horizontally()
            .sizeToFit(.width)

        usersTableView.pin
            .below(of: titleLabel)
            .marginTop(12)
            .horizontally()
            .height(186)

        self.pin.wrapContent()
    }

    // MARK: - Helpers

    func getUserBy(indexPath: IndexPath) -> TopVisitorModelDto? {
        return topVisitorsArray[safe: indexPath.row]
    }

}

// MARK: - UITableViewDataSource

extension StatisticTopVisitorsProfilesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(topVisitorsArray.count, Self.maxUsersInTable)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TopVisitorTableViewCell.className) as? TopVisitorTableViewCell else { return UITableViewCell() }

        if let user = getUserBy(indexPath: indexPath) {
            cell.fillFrom(user: user)
            cell.setIsLast(indexPath.row == min(topVisitorsArray.count, Self.maxUsersInTable))
        }

        return cell
    }
    

}

// MARK: - UITableViewDelegate

extension StatisticTopVisitorsProfilesView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HighlightableCell
        cell?.setCellHighlighted(true)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HighlightableCell
        cell?.setCellHighlighted(false)
    }

}
