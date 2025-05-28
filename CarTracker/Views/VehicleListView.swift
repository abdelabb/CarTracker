import SwiftUI

import SwiftUI

struct VehicleListView: View {
    @StateObject var viewModel = VehicleViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(viewModel.vehicles.enumerated()), id: \.element.id) { index, vehicle in
                    NavigationLink(
                        destination: VehicleDetailView(vehicle: $viewModel.vehicles[index], viewModel: viewModel)
                    ) {
                        VStack(alignment: .leading) {
                            Text(vehicle.name).font(.headline)
                            Text(vehicle.registration).font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Mes véhicules")
            .toolbar {
                NavigationLink("Ajouter", destination: AddVehicleView(viewModel: viewModel))
            }
        }
    }
}

