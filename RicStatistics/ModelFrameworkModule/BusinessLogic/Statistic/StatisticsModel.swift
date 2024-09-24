
import Foundation
import RealmSwift
import RxSwift

final class StatisticsModel {

    typealias VisitorsTrendData = (visitorsByMonth: [Int], trend: Int)

    // MARK: - Data / Bindings

    private let topUsersSubject = BehaviorSubject<[RLMUser]>(value: [])
    var topVisitorsObservable: Observable<[RLMUser]> { return topUsersSubject.asObservable() }

    private let isLoadingSubject: BehaviorSubject<Bool> = .init(value: false)
    var isLoadingObservable: Observable<Bool> { return isLoadingSubject.asObservable() }

    private let visitorsTrendSubject = BehaviorSubject<StatisticTrendModelDto>(value: .init())
    var visitorsTrendSubjectObservable: Observable<StatisticTrendModelDto> {
        return visitorsTrendSubject.asObservable()
    }

    private let subscriptionsTrendSubject = BehaviorSubject<StatisticTrendModelDto>(value: .init())
    var subscriptionsTrendSubjectObservable: Observable<StatisticTrendModelDto> {
        return subscriptionsTrendSubject.asObservable()
    }

    private let unsubscriptionsTrendSubject = BehaviorSubject<StatisticTrendModelDto>(value: .init())
    var unsubscriptionsTrendSubjectObservable: Observable<StatisticTrendModelDto> {
        return unsubscriptionsTrendSubject.asObservable()
    }

    // MARK: - Services

    private let defaultsManager: UserDefaultsManager
    private let networkService: NetworkService
    private let realmManager: RealmManager
    private let dateStatisticService: DateStatisticsService

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

                defaultsManager.isStatisticLoaded = true
                self.loadDataFromRealm()
            }
        } else {
            Task { @MainActor [weak self] in
                self?.loadDataFromRealm()
            }
        }
    }

    private func loadDataFromRealm() {
        let rlmStatistics = realmManager.getObjects(RLMStatisticItem.self)

        let usersIds = Array(rlmStatistics).compactMap { $0.user?.id }
        let rlmUsers = realmManager.getUsersBy(ids: usersIds)

        let visitorsTrendResult = calculateVisisorsTrendResult(from: rlmStatistics, for: .view)
        let subscriptionsTrendResult = calculateVisisorsTrendResult(from: rlmStatistics, for: .subscription)
        let unsubscriptionsTrendResult = calculateVisisorsTrendResult(from: rlmStatistics, for: .unsubscription)

        visitorsTrendSubject.onNext(visitorsTrendResult)
        subscriptionsTrendSubject.onNext(subscriptionsTrendResult)
        unsubscriptionsTrendSubject.onNext(unsubscriptionsTrendResult)
        topUsersSubject.onNext(Array(rlmUsers))
        isLoadingSubject.onNext(false)
    }

    // MARK: - PrepareData for Result DTO

    func calculateVisisorsTrendResult(
        from rlmStatistics: Results<RLMStatisticItem>,
        for itemType: RLMStatisticItemType
    ) -> StatisticTrendModelDto {
        let items = Array(rlmStatistics.filter { $0.type == itemType })
        let allDates = items.flatMap { $0.dates }

        let countByMonths = dateStatisticService.calculateDatesCountByMonts(fromDates: allDates, countMonth: 6)
        let countByMonthsFlat = countByMonths.map { $0.count }
        let delta = dateStatisticService.calculateDeltaForLastMonth(countsByMonths: countByMonths)

        var trendType: TrendType? = nil
        if let delta {
            trendType = dateStatisticService.calculateTrendTypeFor(delta: delta)
        }

        return .init(
            countByPeriod: countByMonthsFlat,
            trendType: trendType ?? .flat,
            delta: delta ?? 0
        )
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

}
