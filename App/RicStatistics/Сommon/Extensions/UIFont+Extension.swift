
import UIKit

extension UIFont {

    static let gilroyBold: Custom = .gilroyBold
    static let gilroySemiBold: Custom = .gilroySemiBold
    static let gilroyMedium: Custom = .gilroyMedium

    enum Custom: String {
        case gilroyBold = "Gilroy-Bold"
        case gilroySemiBold = "Gilroy-Semibold"
        case gilroyMedium = "Gilroy-Medium"

        func withSize(_ size: CGFloat) -> UIFont {
            return UIFont(name: self.rawValue, size: size) ?? .systemFont(ofSize: size)
        }
    }
}
