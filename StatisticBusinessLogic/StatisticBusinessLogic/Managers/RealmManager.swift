
import Foundation
import RealmSwift

public class RealmManager {
    public static let shared = RealmManager()

    private var realm: Realm

    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Error initializing Realm: \(error.localizedDescription)")
        }
    }

    // MARK: - User

    func getUsersBy(ids: [Int]) -> Results<RLMUser> {
        return getObjects(RLMUser.self)
            .filter("\(RLMUser.keyId) IN %@", ids)
    }

    // MARK: - Helpers


    func getObjectById<T: Object>(_ type: T.Type, id: String) -> T? {
        return realm.object(ofType: type, forPrimaryKey: id)
    }

    func getObjects<T: Object>(_ type: T.Type) -> Results<T> {
            return realm.objects(type)
        }

    func addObject<T: Object>(_ object: T) throws {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            throw RealmManagerError.errorWhieAdding(description: error.localizedDescription)
        }
    }

    private func updateObject(_ object: Object, with dictionary: [String: Any?]) throws {
        do {
            try realm.write {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            throw RealmManagerError.errorWhileUpdate(description: error.localizedDescription)
        }
    }

    func deleteAllObjects<T: Object>(withType type: T.Type) throws {
        do {
            try realm.write {
                let objects = realm.objects(type)
                realm.delete(objects)
            }
        } catch {
            throw RealmManagerError.errorWhileDeleting(description: error.localizedDescription)
        }
    }

}
