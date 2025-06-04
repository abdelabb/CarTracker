//
//  PremiumDebugView.swift
//  CarTracker
//
//  Created by abbas on 03/06/2025.
//

import SwiftUI

struct PremiumDebugView: View {
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    @StateObject private var viewModel = VehicleViewModel()
    var brand: String = "Tesla"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🔧 Mode Test Premium")
                    .font(.title2)
                    .fontWeight(.semibold)

                Toggle(isOn: $isPremiumUser) {
                    Text(isPremiumUser ? "Premium activé ✅" : "Premium désactivé ❌")
                        .font(.headline)
                        .foregroundColor(isPremiumUser ? .green : .red)
                }
                .padding()

                Button("Ajouter un véhicule de test") {
                    let newVehicle = Vehicle(name: "Véhicule Test", brand: brand, registration: "TEST123")
                    viewModel.addVehicle(newVehicle)
                    print("🚗 Véhicule ajouté")
                }
                .buttonStyle(.borderedProminent)

                Button("Supprimer tous les véhicules") {
                    viewModel.vehicles.removeAll()
                    print("🗑️ Tous les véhicules supprimés (local + iCloud)")
                }
                .foregroundColor(.red)

                Spacer()
            }
            .padding()
            .navigationTitle("Débogage Premium")
        }
    }
}
