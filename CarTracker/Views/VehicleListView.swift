import SwiftUI

struct VehicleListView: View {
    @StateObject var viewModel = VehicleViewModel()
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    @State private var showLimitAlert = false
    @State private var showRestoreAlert = false
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        VStack(spacing: 16) {
            UpgradeView()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.1))
                )
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                .transition(.scale)

            List {
                ForEach(viewModel.vehicles) { vehicle in
                    NavigationLink(
                        destination: VehicleDetailView(vehicle: vehicle, viewModel: viewModel)
                    ) {
                        vehicleRow(vehicle)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteVehicle)
            }
            .listStyle(.plain)
            .padding(.horizontal)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)

            // 🔄 Bouton pour restaurer iCloud
            Button("🔄 Restaurer depuis iCloud") {
                if isPremiumUser {
                    viewModel.restoreFromICloud()
                } else {
                    showRestoreAlert = true
                }
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .alert("Accès réservé", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("🔒 Restauration iCloud disponible uniquement pour les utilisateurs Premium.")
            }

            Button("🗑 Supprimer tous les véhicules localement") {
                viewModel.vehicles.removeAll()
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            
            Button("👤 Gérer mon abonnement") {
                storeManager.openSubscriptionManagement()
            }
            .buttonStyle(.bordered)
            .tint(.gray)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)

#if DEBUG
Button(isPremiumUser ? "❌ Désactiver Premium (Test)" : "✅ Activer Premium (Test)") {
    isPremiumUser.toggle()
    print(isPremiumUser ? "🧪 Premium activé manuellement" : "🧪 Premium désactivé manuellement")
}
.font(.caption)
.padding(8)
.background(isPremiumUser ? Color.red.opacity(0.3) : Color.yellow.opacity(0.3))
.cornerRadius(12)
#endif
        }
        .navigationTitle("Mes véhicules")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if isPremiumUser || viewModel.vehicles.count < 1 {
                        navigateToAddVehicle()
                    } else {
                        showLimitAlert = true
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .alert("Limite atteinte", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Vous devez passer à la version Premium pour ajouter plus d'un véhicule.")
        }
    }

    private func navigateToAddVehicle() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.present(
                UIHostingController(rootView: AddVehicleView(viewModel: viewModel)),
                animated: true
            )
        }
    }

    private func deleteVehicle(at offsets: IndexSet) {
        viewModel.vehicles.remove(atOffsets: offsets)
    }
    // Ajoute cette fonction dans la struct
    @ViewBuilder
    private func vehicleRow(_ vehicle: Vehicle) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
                Image(systemName: "car.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 24, weight: .bold))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(vehicle.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(vehicle.registration)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground).opacity(0.95))
        )
        .scaleEffect(1.02)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
