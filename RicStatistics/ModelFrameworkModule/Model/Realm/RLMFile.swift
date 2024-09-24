
import Foundation
import RealmSwift

class RLMFile: Object {

    // MARK: - Fields properties

    @Persisted(primaryKey: true) var id: Int
    @Persisted var url: String
    @Persisted var typeRawValue: String

    var type: FileType {
        get { .init(rawValue: typeRawValue) ?? .unknown }
        set { typeRawValue = newValue.rawValue }
    }
}
