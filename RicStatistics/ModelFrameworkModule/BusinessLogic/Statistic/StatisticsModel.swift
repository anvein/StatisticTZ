
import Foundation
import RealmSwift
import RxSwift

final class StatisticsModel {

    // MARK: - Services

    private let defaultsManager: UserDefaultsManager
    private let networkService: NetworkService
    private let realmManager: RealmManager
    private let dateStatisticService: DateStatisticsService

    // MARK: - State

    var visitorsByPeriodFilter: VisitorsStatisticPeriod = .byDay

    // MARK: - Data / Bindings

    private let isLoadingSubject: BehaviorSubject<Bool> = .init(value: false)
    var isLoadingObservable: Observable<Bool> { return isLoadingSubject.asObservable() }

    private let visitorsByPeriodsSubject = BehaviorSubject<VisitorsByPeriodsModelDto>(
        value: .init(countByPeriods: [], period: .byDay)
    )
    var visitorsByPeriodsObservable: Observable<VisitorsByPeriodsModelDto> {
        return visitorsByPeriodsSubject.asObservable()
    }

    private let visitorsTrendSubject = BehaviorSubject<VisitorsTrendModelDto>(value: .init())
    var visitorsTrendSubjectObservable: Observable<VisitorsTrendModelDto> {
        return visitorsTrendSubject.asObservable()
    }

    private let topVisitorsSubject = BehaviorSubject<[TopVisitorModelDto]>(value: [])
    var topVisitorsObservable: Observable<[TopVisitorModelDto]> { return topVisitorsSubject.asObservable() }

    private let subscriptionsTrendSubject = BehaviorSubject<ObserversTrendModelDto>(value: .init())
    var subscriptionsTrendSubjectObservable: Observable<ObserversTrendModelDto> {
        return subscriptionsTrendSubject.asObservable()
    }

    private let unsubscriptionsTrendSubject = BehaviorSubject<ObserversTrendModelDto>(value: .init())
    var unsubscriptionsTrendSubjectObservable: Observable<ObserversTrendModelDto> {
        return unsubscriptionsTrendSubject.asObservable()
    }

    // MARK: - Init

    init(
        defaultsManager: UserDefaultsManager = .shared,
        networkService: NetworkService = .shared,
        realmManager: RealmManager = .shared,
        dateStatisticService: DateStatisticsService = .init()
    ) {
        self.defaultsManager = defaultsManager
        self.networkService = networkService
        self.realmManager = realmManager
        self.dateStatisticService = dateStatisticService
    }

    // MARK: - Load data

    func loadData(forceReload: Bool = false) async {
        if !defaultsManager.isStatisticLoaded || forceReload {
            async let usersResponse = networkService.getUsers()
            async let statisticsResponse = networkService.getStatistics()

            let responses = await (usersResponse: try! usersResponse, statisticsResponse: try! statisticsResponse)

            Task { @MainActor [weak self, defaultsManager] in
                guard let self else { return }

                try? self.removeDataInRealm()

                try? self.saveUsersWithFilesToRealmFrom(responses.usersResponse)

                let usersIds = responses.statisticsResponse.getUsersIds()
                let rlmUsers = realmManager.getUsersBy(ids: usersIds)

                try? self.saveStatisticsToRealmFrom(responses.statisticsResponse, with: rlmUsers)

                self.loadDataFromRealm()
                defaultsManager.isStatisticLoaded = true
            }
        } else {
            Task { @MainActor [weak self] in
                self?.loadDataFromRealm()
            }
        }
    }

    func reloadVisitorsByPeriodsData() {
        let rlmStatistics = realmManager.getObjects(RLMStatisticItem.self)
        let visitorsByPeriods = calculateVisitorsByPeriod(rlmStatistics)
        visitorsByPeriodsSubject.onNext(visitorsByPeriods)
    }

    private func loadDataFromRealm() {
        let rlmStatistics = realmManager.getObjects(RLMStatisticItem.self)

        let visitorsTrendResult = calculateVisisorsTrendResult(from: rlmStatistics)
        let subscriptionsTrendResult = calculateObserversTrendResult(from: rlmStatistics, for: .subscription)
        let unsubscriptionsTrendResult = calculateObserversTrendResult(from: rlmStatistics, for: .unsubscription)
        let topVisitorsResult = calculateTopVisitors(rlmStatistics: rlmStatistics)
        let visitorsByPeriods = calculateVisitorsByPeriod(rlmStatistics)

        visitorsTrendSubject.onNext(visitorsTrendResult)
        visitorsByPeriodsSubject.onNext(visitorsByPeriods)
        subscriptionsTrendSubject.onNext(subscriptionsTrendResult)
        unsubscriptionsTrendSubject.onNext(unsubscriptionsTrendResult)
        topVisitorsSubject.onNext(topVisitorsResult)
        isLoadingSubject.onNext(false)
    }

    // MARK: - Calculate Result

    func calculateVisisorsTrendResult(from rlmStatistics: Results<RLMStatisticItem>) -> VisitorsTrendModelDto {
        let items = Array(rlmStatistics.filter { $0.type == .view })
        let allDates = items.flatMap { $0.dates }

        let countByMonths = dateStatisticService.calculateDatesCountByMonths(fromDates: allDates, countMonth: 6)
        var countByMonthsFlat = countByMonths.map { $0.count }
        countByMonthsFlat = countByMonthsFlat.reversed()

        let trendType = dateStatisticService.calculateTrendTypeFor(countByMonthsFlat)
        let countInCurrentMonth = countByMonthsFlat.last ?? 0

        return .init(
            countByPeriods: countByMonthsFlat,
            trendType: trendType ?? .flat,
            countInCurrentMonth: countInCurrentMonth
        )
    }

    func calculateObserversTrendResult(
        from rlmStatistics: Results<RLMStatisticItem>,
        for itemType: RLMStatisticItemType
    ) -> ObserversTrendModelDto {
        let items = Array(rlmStatistics.filter { $0.type == itemType })
        let allDates = items.flatMap { $0.dates }

        let countByMonths = dateStatisticService.calculateDatesCountByMonths(fromDates: allDates, countMonth: 6)
        var countByMonthsFlat = countByMonths.map { $0.count }
        countByMonthsFlat = countByMonthsFlat.reversed()

        let lastMonthCount = countByMonthsFlat.last ?? 0

        return .init(
            countByPeriods: countByMonthsFlat,
            countInCurrentPeriod: lastMonthCount
        )
    }

    func calculateTopVisitors(
        rlmStatistics: Results<RLMStatisticItem>
    ) -> [TopVisitorModelDto] {
        let viewStatisticItems = rlmStatistics
            .filter("\(RLMStatisticItem.keyTypeRawValue) == '\(RLMStatisticItemType.view.rawValue)'")

        var userCountViews: [Int: Int] = [:]
        for item in viewStatisticItems {
            guard let userId = item.user?.id else { continue }

            userCountViews[userId, default: 0] += item.dates.count
        }
        let topUsersIdsSortedByCount = userCountViews.sorted(by: { $0 > $1 }).prefix(3)
        let topUsersIdsFlat = topUsersIdsSortedByCount.map { $0.key }

        let topUsers = realmManager.getUsersBy(ids: topUsersIdsFlat)
        let topUsersSortedByCount = topUsersIdsFlat.compactMap { id in
            topUsers.first(where: { $0.id == id })
        }

        let topVisitorsArray: [TopVisitorModelDto] = topUsersSortedByCount.map { user in
            return convertRealmUserToTopVisitorsDto(user)
        }

        return topVisitorsArray
    }

    func calculateVisitorsByPeriod(_ statisticItems: Results<RLMStatisticItem>) -> VisitorsByPeriodsModelDto {
        let filterFieldKey = RLMStatisticItem.keyTypeRawValue
        let filterFieldValue = RLMStatisticItemType.view.rawValue
        let visitItems = statisticItems.filter("\(filterFieldKey) == '\(filterFieldValue)'")

        let allDates = visitItems.flatMap { $0.dates }
        let result = calculateCounts(by: visitorsByPeriodFilter, from: Array(allDates))

        return VisitorsByPeriodsModelDto(
            countByPeriods: result,
            period: visitorsByPeriodFilter
        )
    }


    func countDatesEqualToDate(from dates: [Date], date: Date) -> Int {
        let calendar = Calendar.current
        return dates.filter {
            calendar.isDate($0, equalTo: date, toGranularity: .day)
        }.count
    }

    func calculateCounts(by period: VisitorsStatisticPeriod, from dates: [Date]) -> [CountByPeriodModelDto] {
        let calendar = Calendar.current
        var groupedDates: [CountByPeriodModelDto] = []

        let sortedDates = dates.sorted { $0 > $1 }
        let currentDate = Date()

        for iPeriod in 0..<period.periodLength {
            switch period {
            case .byDay:
                let periodDay = calendar.date(byAdding: .day, value: -iPeriod, to: currentDate)
                guard let periodDay else { continue }

                let count = countDatesEqualToDate(from: sortedDates, date: periodDay)

                groupedDates.append(CountByPeriodModelDto(value: count, day: periodDay))



            case .byWeek:
                break
//                let weekOfYear = calendar.component(.weekOfYear, from: date)
//                let year = calendar.component(.year, from: date)
//                key = "Week \(weekOfYear), \(year)" // Группировка по неделям

            case .byMonth:
                break
//                let monthFormatter = DateFormatter()
//                monthFormatter.dateFormat = "MMMM yyyy"
//                key = monthFormatter.string(from: date) // Группировка по месяцам
            }


        }

//        for date in dates {
//            var key: String
//
//            switch period {
//            case .byDay:
//                key = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none) // Группировка по дням
//
//            case .byWeek:
//                let weekOfYear = calendar.component(.weekOfYear, from: date)
//                let year = calendar.component(.year, from: date)
//                key = "Week \(weekOfYear), \(year)" // Группировка по неделям
//
//            case .byMonth:
//                let monthFormatter = DateFormatter()
//                monthFormatter.dateFormat = "MMMM yyyy"
//                key = monthFormatter.string(from: date) // Группировка по месяцам
//            }
//
//            groupedDates[key, default: 0] += 1
//        }

        return groupedDates

//        return [:]
    }

    // MARK: - Add Users data to Realm

    private func saveUsersWithFilesToRealmFrom(_ response: CPGUsersReponse) throws {
        for apiUser in response.users {
            let apiAvatarFile = apiUser.getFileWith(type: .avatar)
            var rlmAvatarFile: RLMFile? = nil
            if let apiAvatarFile {
                rlmAvatarFile = buildRealmFileFrom(apiAvatarFile)

                if let rlmAvatarFile {
                    try realmManager.addObject(rlmAvatarFile)
                }
            }

            let rlmUser = buildRealmUserFrom(apiUser)
            rlmUser.avatar = rlmAvatarFile

            try realmManager.addObject(rlmUser)
        }
    }

    private func buildRealmUserFrom(_ apiUser: CPGUser) -> RLMUser {
        let rlmUser = RLMUser()
        rlmUser.id = apiUser.id
        rlmUser.username = apiUser.username
        rlmUser.age = apiUser.age
        rlmUser.isOnline = apiUser.isOnline

        return rlmUser
    }

    private func buildRealmFileFrom(_ apiFile: CPGFile) -> RLMFile {
        let rlmFile = RLMFile()
        rlmFile.id = apiFile.id
        rlmFile.url = apiFile.url

        switch apiFile.type {
        case .avatar:
            rlmFile.type = .avatar
        }

        return rlmFile
    }

    // MARK: - Add Statistic data to Realm

    private func saveStatisticsToRealmFrom(_ response: CPGStatisticsResponse, with rlmUsers: Results<RLMUser>) throws {
        let usersDict = rlmUsers.reduce(into: [Int: RLMUser]()) { dict, user in
            dict[user.id] = user
        }

        for apiStatisticItem in response.statistics {
            let rlmUser = usersDict[apiStatisticItem.userId]
            let rlmStatisticItem = buildRealmStatisticFrom(apiStatisticItem, with: rlmUser)

            try realmManager.addObject(rlmStatisticItem)
        }
    }

    private func buildRealmStatisticFrom(
        _ apiStatisticItem: CPGStatisticsResponse.Item, with rlmUser: RLMUser?
    ) -> RLMStatisticItem {
        let rlmStatisticItem = RLMStatisticItem()
        rlmStatisticItem.type = convertToTypeToRealmStatisticTypeFrom(apiStatisticItem.type)
        rlmStatisticItem.dates.append(objectsIn: apiStatisticItem.dates)
        rlmStatisticItem.user = rlmUser
        return rlmStatisticItem
    }

    private func convertToTypeToRealmStatisticTypeFrom(_ apiType: CPGStatisticsResponse.ItemType) -> RLMStatisticItemType {
        switch apiType {
        case .subscription:
            return .subscription
        case .unsubscription:
            return .unsubscription
        case .view:
            return .view
        }
    }

    private func removeDataInRealm() throws {
        try realmManager.deleteAllObjects(withType: RLMStatisticItem.self)
        try realmManager.deleteAllObjects(withType: RLMUser.self)
        try realmManager.deleteAllObjects(withType: RLMFile.self)
    }

    // MARK: - Helpers

    func convertRealmUserToTopVisitorsDto(_ user: RLMUser) -> TopVisitorModelDto {
        return .init(
            id: user.id,
            avatarUrl: user.avatar?.url,
            avatarData: nil,
            username: user.username,
            isOnline: user.isOnline,
            age: user.age
        )
    }

}
