//
//  VehicleDetailView.swift
//  CarTracker
//
//  Created by abbas on 27/05/2025.
//

import SwiftUI

struct VehicleDetailView: View {
    @Binding var vehicle: Vehicle
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
                            Text("Remarques : \(record.notes)")
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
