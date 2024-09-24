
import Foundation

enum CPGRoute: ApiRoute {
    // MARK: - Cases

    case statistics
    case usersList

    // MARK: - Route Params

    var host: String { "https://cars.cprogroup.ru" }

    var endpoint: String {
        switch self {
        case .statistics: return "/api/episode/statistics/"
        case .usersList: return "/api/episode/users/"
        }
    }

    var queryParams: [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }

    var method: APIHttpMethod {
        switch self {
        case .usersList, .statistics :
            return .get
        }
    }

    var headers: [String : String]? {
        switch self {
        case .usersList, .statistics :
            return nil
        }
    }

}
