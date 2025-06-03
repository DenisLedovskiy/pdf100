import Foundation
import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.locale = priceLocale
        formatter.numberStyle = .currency
        return formatter.string(from: price) ?? ""
    }

    var pricePerWeek: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let price = (price as Decimal) / 52
        return formatter.string(from: NSNumber(value: Double("\(price)") ?? 0)) ?? ""
    }

    var weeklySubscriptionPrice: Double? {
        let price = self.price
        let yearlyPrice = price.doubleValue
        let weeksInYear = 52.0
        let weeklyPrice = yearlyPrice / weeksInYear
        return weeklyPrice
    }

    var weeklyPrice: String? {
        guard let priceDecimal = self.price as Decimal? else { return nil }
        let priceInCents = priceDecimal as NSDecimalNumber
        let weeksInAYear: Decimal = 52
        let weeklyPrice = priceInCents.decimalValue / weeksInAYear
        return String(format: "%.2f", NSDecimalNumber(decimal: weeklyPrice).doubleValue)
    }
}
