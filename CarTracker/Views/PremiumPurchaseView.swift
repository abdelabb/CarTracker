//
//  PremiumPurchaseView.swift
//  CarTracker
//
//  Created by abbas on 06/06/2025.
//

import SwiftUI
import StoreKit

struct PremiumPurchaseView: View {
    @Environment(\.dismiss) var dismiss
    @State private var product: Product?
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 24) {
            if isLoading {
                ProgressView("Chargement de l'offre…")
            } else if let product {
                VStack(spacing: 12) {
                    Text("⭐️ Premium Plus")
                        .font(.largeTitle.bold())

                    Text(product.description)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)

                    Text(product.displayPrice)
                        .font(.title2.bold())

                    Button("S'abonner maintenant") {
                        Task {
                            try? await product.purchase()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            } else {
                Text("Aucune offre disponible.")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .task {
            await fetchProduct()
        }
    }

    private func fetchProduct() async {
        do {
            let storeProducts = try await Product.products(for: ["com.abdelmalekabbas.CarTracker.premiumplus"])
            self.product = storeProducts.first
        } catch {
            print("❌ Erreur récupération produit : \(error)")
        }
        isLoading = false
    }
}
