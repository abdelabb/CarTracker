import SwiftUI

struct VehicleDetailView: View {
    @ObservedObject var vehicle: Vehicle
    var viewModel: VehicleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(vehicle.name)
                .font(.largeTitle)
                .bold()

            Text("Immatriculation : \(vehicle.registration)")
                .font(.headline)

            if !vehicle.maintenanceRecords.isEmpty {
                Text("Entretiens")
                    .font(.title2)
                    .padding(.top)

                List {
                    ForEach(vehicle.maintenanceRecords) { record in
                        VStack(alignment: .leading) {
                            Text(record.type)
                                .font(.headline)
                            Text("Date : \(record.date.formatted(date: .abbreviated, time: .omitted))")
                            Text("Km : \(record.mileage)")
                            Text("Coût : \(String(format: "%.2f €", record.cost))")
                            if !record.notes.isEmpty {
                                Text("Remarques : \(record.notes)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                Text("Aucun entretien enregistré.")
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
        }
        .toolbar {
            NavigationLink("Ajouter Entretien") {
                AddMaintenanceView(vehicle: vehicle, viewModel: viewModel)
            }
        }
        .padding()
        .navigationTitle("Détail véhicule")
    }
}
