//
//  ContentView.swift
//  CarTracker
//
//  Created by abbas on 27/05/2025.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        if storeManager.isSubscribed(productID: "com.abdelmalekabbas.CarTracker.premiumplus") {
                   // L'utilisateur est abonné
                   PremiumContentView()
               } else {
                   // L'utilisateur n'est pas abonné
                   UpgradeView()
               }
            VehicleListView()
                
        
    }
}

#Preview {
    ContentView()
}
