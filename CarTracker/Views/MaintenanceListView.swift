//
//  MaintenanceListView.swift
//  CarTracker
//
//  Created by abbas on 27/05/2025.
//


import SwiftUI

struct MaintenanceListView: View {
    var maintenanceRecords: [MaintenanceEntry]

    var body: some View {
        List(maintenanceRecords) { record in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(record.type)
                        .font(.headline)
                    Spacer()
                    Text(record.date.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }

                Text("Kilométrage : \(record.mileage) km")
                    .font(.subheadline)

                Text("Prix : \(String(format: "%.2f", record.cost)) €")
                    .font(.subheadline)

                if !record.notes.isEmpty {
                    Text("Remarque : \(record.notes)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Entretiens")
    }
}

#Preview {
    NavigationView {
        MaintenanceListView(maintenanceRecords: [
            MaintenanceEntry(type: "Vidange", date: .now, mileage: 120000, cost: 89.99, notes: "Avec changement de filtre."),
            MaintenanceEntry(type: "Freins", date: .now, mileage: 118000, cost: 120.00, notes: "Plaquettes avant remplacées.")
        ])
    }
}
