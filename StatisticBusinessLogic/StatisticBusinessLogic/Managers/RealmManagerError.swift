
import Foundation

enum RealmManagerError: Error {
    case errorWhileUpdate(description: String)
    case errorWhieAdding(description: String)
    case errorWhileDeleting(description: String)
}
