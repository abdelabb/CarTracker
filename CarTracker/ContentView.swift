import SwiftUI

struct ContentView: View {

    @EnvironmentObject var storeManager: StoreManager
    @StateObject var viewModel = VehicleViewModel()
    @State private var showAlert = false
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 💎 Bannière abonnement
                UpgradeView()
                    .environmentObject(storeManager)
                    .environmentObject(viewModel)

                // 🚗 Liste des véhicules
                VehicleListView()
                    .environmentObject(viewModel)

                // 📊 Accès stats — en bas uniquement
                Divider()
                    .padding(.vertical, 8)

                Button {
                   // if storeManager.isSubscribed(productID: "com.abdelmalekabbas.CarTracker.premiumplus")
                    if storeManager.isSubscribed(productID: "com.abdelmalekabbas.CarTracker.premiumplus") || isPremiumUser
                    {
                        // Navigation vers les stats
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            UIApplication.shared.windows.first?.rootViewController?.present(
                                UIHostingController(rootView: MaintenanceStatsView(viewModel: viewModel)),
                                animated: true
                            )
                        }
                    } else {
                        showAlert = true
                    }
                } label: {
                    Label("📊 Voir les statistiques d’entretien", systemImage: "chart.bar.xaxis")
                        .font(.subheadline)
                        .foregroundColor(
                            (storeManager.isSubscribed(productID: "com.abdelmalekabbas.CarTracker.premiumplus") || isPremiumUser)
                            ? .accentColor
                            : .gray
                        )
                        .padding(.bottom, 12)
                }
                
                .alert("Fonctionnalité Premium", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Abonnez-vous à Premium Plus pour accéder aux statistiques.")
                }
#if DEBUG
Divider()
Button(action: {
    isPremiumUser.toggle()
    print("🔧 isPremiumUser:", isPremiumUser)
}) {
    Text(isPremiumUser ? "🔁 Revenir à la version gratuite" : "🔓 Activer Premium (test)")
        .font(.footnote)
        .foregroundColor(.blue)
        .padding(.bottom, 12)
}
#endif
            }
            .navigationTitle("Mes véhicules")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
