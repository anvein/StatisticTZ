
import Foundation

struct CPGFile: Codable {
    let id: Int
    let url: String
    let type: FileType
}

// MARK: - CGPFile.FileType

extension CPGFile {
    enum FileType: String, Codable {
        case avatar
    }
}
