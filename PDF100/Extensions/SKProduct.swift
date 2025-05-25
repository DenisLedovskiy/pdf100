import Foundation
import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.locale = priceLocale
        formatter.numberStyle = .currency
        return formatter.string(from: price) ?? ""
    }
}
