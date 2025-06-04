import SwiftUI

struct VehicleListView: View {
    @StateObject var viewModel = VehicleViewModel()
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    @State private var showLimitAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("PrimaryBackground"),
                        Color("SecondaryBackground")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                List {
                    ForEach(Array(viewModel.vehicles.enumerated()), id: \.1.id) { index, vehicle in
                        NavigationLink(
                            destination: VehicleDetailView(vehicle: viewModel.vehicles[index], viewModel: viewModel)
                        ) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.13))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "car.fill")
                                        .foregroundColor(.accentColor)
                                        .font(.system(size: 22, weight: .bold))
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(vehicle.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(vehicle.registration)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray.opacity(0.4))
                            }
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground).opacity(0.7))
                                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                            )
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteVehicle)
                }
                .listStyle(.plain)
                .padding(.top, 4)
            }
            .navigationTitle("Mes véhicules")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if isPremiumUser || viewModel.vehicles.count < 1 {
                            // L'utilisateur peut ajouter un véhicule
                            navigateToAddVehicle()
                        } else {
                            showLimitAlert = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .bold))
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
    }

    private func navigateToAddVehicle() {
        // Utilise une NavigationLink cachée ou une redirection programmatique selon ton architecture
        // Ici un exemple simple à adapter selon ta navigation :
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
}
