
import Foundation

final class NetworkService: BaseNetworkService {

    // MARK: - Singletone

    static var shared: NetworkService = .init()

    init() { }

    // MARK: - Users

    func getUsers() async throws -> CPGUsersReponse {
        return try await getData(route: CPGRoute.usersList)
    }

    // MARK: - Statistics

    func getStatistics() async throws -> CPGStatisticsResponse {
        return try await getData(route: CPGRoute.statistics)
    }

}
