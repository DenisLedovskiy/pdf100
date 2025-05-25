import Foundation
import StoreKit
import ApphudSDK

protocol AppHudManagerDelegate {
    func purchasesWasEnded(success: Bool?, messageError: String)
    func finishLoadPaywall()
}

final class AppHudManager: NSObject {

    enum Products {
        case trialWeek
        case noTrial
    }

    static let shared = AppHudManager()
    @objc dynamic var isLoadInapp = false

    @objc private(set) var products: [SKProduct] = []
    private var productIds : Set<String> = []

    private var currentProduct: SKProduct?
    var subscription: ApphudProduct?
    var subscriptionTrial: ApphudProduct?

    private var productNoTrial: Product?
    private var productTrial: Product?

    var payWallindex: Int = 1
    var isTrialSub = false

    var isPremium: Bool { Apphud.hasActiveSubscription() }

    var isSubscribed: Bool = false

    var delegate: AppHudManagerDelegate?

    private override init() {
        super.init()
    }
}

extension AppHudManager {

    func getProducts() {
        Task {
            let paywall = await Apphud.placements(maxAttempts: 3).filter { $0.identifier == "main"}.first?.paywall
            payWallindex = (paywall?.json?["paywall"] as? Int) ?? 1

            guard let count = paywall?.products.count else {return}

            guard count != 1 else {
                let product = try await paywall?.products.first?.product()
                subscription = paywall?.products.first
                productNoTrial = product

                if (product?.subscription?.introductoryOffer) != nil {
                    isTrialSub = true
                } else {
                    isTrialSub = false
                }
                return
            }

            for index in 0...count-1 {
                let product = try await paywall?.products[index].product()
                if (product?.subscription?.introductoryOffer) != nil {
                    subscriptionTrial = paywall?.products[index]
                    productTrial = product
                } else {
                    subscription = paywall?.products[index]
                    productNoTrial = product
                }
            }
        }
    }

    func startPurchase(_ product: ApphudProduct) {
        Task {
            let result = await Apphud.purchase(product)
            if result.success {
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

extension AppHudManager {

    func getPrice(_ type: Products) -> String {
        let price = switch type {
        case .trialWeek:
            productTrial?.displayPrice
        case .noTrial:
            productNoTrial?.displayPrice
        }
        return price ?? ""
    }

    func getDuration(_ type: Products) -> String {
        let durationUnit = switch type {
        case .trialWeek:
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
