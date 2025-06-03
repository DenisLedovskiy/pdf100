import Foundation
import StoreKit
import ApphudSDK

protocol AppHudManagerDelegate {
    func purchasesWasEnded(success: Bool?, messageError: String)
    func finishLoadPaywall()
}

final class MakeDollarService: NSObject {

    enum Products {
        case trial
        case noTrial
    }

    static let shared = MakeDollarService()
    @objc dynamic var isLoadInapp = false

    @objc private(set) var products: [SKProduct] = []
    private var productIds : Set<String> = []

    private var currentProduct: SKProduct?
    var subscriptionNoTrial: ApphudProduct?
    var subscriptionTrial: ApphudProduct?

    private var productNoTrial: Product?
    private var productTrial: Product?

    var isPremium: Bool { Apphud.hasActiveSubscription() }

    var isSubscribed: Bool = false

    var delegate: AppHudManagerDelegate?

    private override init() {
        super.init()
    }
}

extension MakeDollarService {

    func getProducts() {
        Task {
            let paywall = await Apphud.placements(maxAttempts: 3).filter { $0.identifier == "main"}.first?.paywall
            guard let count = paywall?.products.count else {return}

            for index in 0...count-1 {
                let product = try await paywall?.products[index].product()
                if (product?.subscription?.introductoryOffer) != nil {
                    subscriptionTrial = paywall?.products[index]
                    productTrial = product
                } else {
                    subscriptionNoTrial = paywall?.products[index]
                    productNoTrial = product
                }
            }
        }
    }

    func startPurchase(_ product: ApphudProduct) {
        Task {
            let result = await Apphud.purchase(product)
            if result.success {
                QuikManager.shared.updateQuickActions(hasActiveSubscription: true)
                NotificationCenter.default.post(
                    name: .didChangeSubscriptionStatus,
                    object: nil,
                    userInfo: ["isActive": true]
                )
                delegate?.purchasesWasEnded(success: true, messageError: "")
            } else {
                let errorMess = result.error?.localizedDescription
                guard errorMess != "The operation couldn’t be completed. (SKErrorDomain error 2.)" else {
                    self.delegate?.purchasesWasEnded(success: nil, messageError: "")
                    return
                }
                delegate?.purchasesWasEnded(success: false, messageError: result.error?.localizedDescription ?? "Error during subscription payment process")
            }
        }
    }

    func restore() {
        Task {
            await Apphud.restorePurchases()
            if Apphud.hasActiveSubscription(){
                delegate?.purchasesWasEnded(success: true, messageError: "")
            } else {
                delegate?.purchasesWasEnded(success: false, messageError: "No active subscription found")
            }
        }
    }
}

extension MakeDollarService {

    func getYearPerWeekPrice() -> String {
        let currency =  getCurrency(.noTrial)
        let price = subscriptionNoTrial?.skProduct?.weeklyPrice ?? ""
        return "\(currency)\(price)"
    }

    func getCurrency(_ type: Products) -> String {
        return switch type {
        case .trial:
            subscriptionTrial?.skProduct?.priceLocale.currencySymbol ?? ""
        case .noTrial:
            subscriptionNoTrial?.skProduct?.priceLocale.currencySymbol ?? ""
        }
    }

    func getPrice(_ type: Products) -> String {
        let currency =  getCurrency(type)
        let price = switch type {
        case .trial:
            subscriptionTrial?.skProduct?.price.formattedCurrency() ?? ""
        case .noTrial:
            subscriptionNoTrial?.skProduct?.price.formattedCurrency() ?? ""
        }
        return "\(currency)\(price)"
    }

    func getDuration(_ type: Products) -> String {
        let durationUnit = switch type {
        case .trial:
            productTrial?.subscription?.subscriptionPeriod.unit
        case .noTrial:
            productNoTrial?.subscription?.subscriptionPeriod.unit
        }

        let durationString: String = switch durationUnit {
        case .day: trans("/week")
        case .year: trans("/year")
        case .week: trans("/week")
        case .month: trans("/month")
        case .none: ""
        case .some(_): ""
        }

        return durationString
    }
}

extension NSDecimalNumber {

    func formattedCurrency() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: Double("\(self)") ?? 0))
    }
}
