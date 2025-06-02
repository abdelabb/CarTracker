import SwiftUI

struct VehicleListView: View {
    @StateObject var viewModel = VehicleViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Fond dégradé doux pour un effet premium
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("PrimaryBackground"), // Mets-les dans tes Assets ou utilise .blue/.gray
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
                                // Icône véhicule personnalisée
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
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: AddVehicleView(viewModel: viewModel)) {
                        Label("Ajouter", systemImage: "plus")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private func deleteVehicle(at offsets: IndexSet) {
        viewModel.vehicles.remove(atOffsets: offsets)
    }
}
