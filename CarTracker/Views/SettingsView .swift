//
//  SettingsView .swift
//  CarTracker
//
//  Created by abbas on 30/05/2025.
//

import StoreKit
import SwiftUI

struct UpgradeView: View {
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        VStack {
            if let product = storeManager.products.first {
                Text(product.displayName)
                Text(product.displayPrice)

                Button("S'abonner") {
                    Task {
                        await storeManager.purchase(product)
                    }
                }
            } else {
                ProgressView("Chargement...")
            }
        }
        .padding()
    }
}
