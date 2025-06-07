import SwiftUI

struct VehicleTabView: View {
    @StateObject var viewModel = VehicleViewModel()
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    @State private var showPremiumSheet = false
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        TabView {
            // Onglet Véhicules
            NavigationView {
                VehicleListView(viewModel: viewModel)
            }
            .tabItem {
                Label("Véhicules", systemImage: "car.fill")
            }

            // Onglet Statistiques
            NavigationView {
                if isPremiumUser {
                    MaintenanceStatsView(viewModel: viewModel)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)

                        Text("Fonctionnalité Premium")
                            .font(.title2.bold())

                        Text("📊 Les statistiques sont réservées aux utilisateurs Premium.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)

                        Button("Passer à Premium") {
                            showPremiumSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .sheet(isPresented: $showPremiumSheet) {
                            PremiumPurchaseView()
                                .environmentObject(storeManager)
                        }
                    }
                    .padding()
                }
            }
            .tabItem {
                Label("Statistiques", systemImage: "chart.bar.fill")
            }

            // Onglet Mon abonnement
            NavigationView {
                SubscriptionView()
                    .environmentObject(storeManager)
            }
            .tabItem {
                Label("Mon abonnement", systemImage: "person.crop.circle")
            }
        }
    }
}
