
import Foundation
import RealmSwift

class RLMStatisticItem: Object {

    // MARK: - Fields names

    static let keyTypeRawValue = "typeRawValue"

    // MARK: - Fields properties

    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var typeRawValue: String
    @Persisted var dates = List<Date>()
    @Persisted var user: RLMUser?

    var type: RLMStatisticItemType {
        get { return .init(rawValue: typeRawValue) ?? .unknown }
        set { typeRawValue = newValue.rawValue }
    }
}
