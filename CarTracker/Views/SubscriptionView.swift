//
//  SubscriptionView.swift
//  CarTracker
//
//  Created by abbas on 06/06/2025.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var storeManager: StoreManager
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Mon abonnement")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isPremiumUser, let product = storeManager.premiumProduct {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("✅ Abonnement actif :")
                            .font(.title2)
                            .bold()
                        Text("Nom : \(product.displayName)")
                        Text("Prix : \(product.displayPrice)")
                        Text("Description : \(product.description)")
                    }
                    .padding()
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(12)
                } else {
                    Text("🚫 Aucun abonnement actif.")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }

                Button("Gérer mon abonnement sur l’App Store") {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Mon abonnement")
    }
}
