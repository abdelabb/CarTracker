//
//  StoreManager.swift
//  CarTracker
//
//  Created by abbas on 30/05/2025.
//

import StoreKit

class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []

    let productIDs: [String] = [
        "com.abdelmalekabbas.CarTracker.premiumplus"
    ]

    init() {
        Task {
            await requestProducts()
            await updatePurchasedProducts()
        }
    }

    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIDs)
            DispatchQueue.main.async {
                self.products = storeProducts
            }
        } catch {
            print("Erreur lors du chargement des produits : \(error)")
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await updatePurchasedProducts()
                }
            default: break
            }
        } catch {
            print("Erreur d'achat : \(error)")
        }
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                DispatchQueue.main.async {
                    self.purchasedProductIDs.insert(transaction.productID)
                }
            }
        }
    }

    func isSubscribed(productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
}
