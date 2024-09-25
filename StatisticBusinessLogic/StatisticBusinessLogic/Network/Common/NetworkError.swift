
import Foundation

enum NetworkError: Error {
    case invalidUrl
    case invalidResponse
    case parsingResponseError(text: String)
    case undefinedError(text: String)
}
