
import Foundation

struct CPGUser: Codable {
    let id: Int
    let sex: Gender
    let username: String
    let isOnline: Bool
    let age: Int
    let files: [CPGFile]

    func getFileWith(type: CPGFile.FileType) -> CPGFile? {
        return files.first(where: { $0.type == type })
    }
}

// MARK: - CPGUser.Gender

extension CPGUser {
    enum Gender: String, Codable {
        case male = "M"
        case female = "W"
    }
}
