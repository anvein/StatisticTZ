
import Foundation

extension Int {
    func pluralize(forms: (singular: String, few: String, many: String)) -> String {
        let absNumber = abs(self)

        let lastTwoDigits = absNumber % 100
        let lastDigit = absNumber % 10

        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "\(forms.many)"
        }

        switch lastDigit {
        case 1:
            return "\(forms.singular)"
        case 2...4:
            return "\(forms.few)"
        default:
            return "\(forms.many)"
        }
    }
}
