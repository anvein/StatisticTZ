
import Foundation

public class BaseNetworkService {

    private let urlSession: URLSession

    // MARK: - Init

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Base methods

    func getData<T: ApiResponse> (route: ApiRoute) async throws -> T {
        let request = try route.buildRequest()

        do {
            let (data, response) = try await urlSession.data(for: request)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }

            let responseObject = try JSONDecoder().decode(T.self, from: data)

            return responseObject
        } catch let error as DecodingError {
            throw NetworkError.parsingResponseError(text: error.localizedDescription)
        } catch {
            throw NetworkError.undefinedError(text: error.localizedDescription)
        }
    }
}
