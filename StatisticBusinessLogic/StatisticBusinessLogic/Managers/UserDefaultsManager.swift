
import Foundation

public final class UserDefaultsManager {

    public static var shared: UserDefaultsManager = .init()

    // MARK: - Parameters keys

    private static let keyIsStatisticLoadedKey = "isStatisticLoaded"

    // MARK: - Services

    private let defaults = UserDefaults.standard

    // MARK: - Params

    var isStatisticLoaded: Bool {
        get { return defaults.bool(forKey: Self.keyIsStatisticLoadedKey) }
        set { defaults.set(newValue, forKey: Self.keyIsStatisticLoadedKey) }
    }

    // MARK: - Init

    private init() { }

}
