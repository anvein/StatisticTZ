
import Foundation
import RealmSwift

class RLMUser: Object {

    // MARK: - Fields names

    static let keyId = "id"

    // MARK: - Fields properties

    @Persisted(primaryKey: true) var id: Int
    @Persisted var username: String
    @Persisted var sexRawValue: String
    @Persisted var isOnline: Bool
    @Persisted var age: Int
    @Persisted var avatar: RLMFile?

    var sex: RLMGender {
        get { RLMGender(rawValue: sexRawValue) ?? .unknown }
        set { sexRawValue = newValue.rawValue }
    }
}
