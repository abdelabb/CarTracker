//
//  AddMaintenanceView.swift
//  CarTracker
//
//  Created by abbas on 27/05/2025.
//

import SwiftUI

struct AddMaintenanceView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vehicle: Vehicle
    var viewModel: VehicleViewModel

    @State private var type = ""
    @State private var date = Date()
    @State private var mileage = ""
    @State private var cost = ""
    @State private var notes = ""
    @State private var showAlert = false

    var body: some View {
        Form {
            Section(header: Text("Type d'entretien")) {
                TextField("Ex: Vidange, Freins...", text: $type)
            }

            Section(header: Text("Détails")) {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Kilométrage", text: $mileage)
                    .keyboardType(.numberPad)
                TextField("Coût (€)", text: $cost)
                    .keyboardType(.decimalPad)
                TextField("Remarques", text: $notes)
            }

            Button("Enregistrer") {
                let newEntry = MaintenanceEntry(
                    type: type,
                    date: date,
                    mileage: Int(mileage) ?? 0,
                    cost: Double(cost) ?? 0.0,
                    notes: notes
                )

                // ➕ Ajouter l'entretien
                vehicle.maintenanceRecords.append(newEntry)

                // 💾 Sauvegarder les données
                viewModel.save()

                // 🔔 Planifier la notification
                NotificationManager.shared.scheduleNotification(
                    for: vehicle.name,
                    type: type,
                    on: Calendar.current.date(byAdding: .day, value: 180, to: date) ?? date
                )

                // ✅ Afficher l'alerte de confirmation
                showAlert = true
            }
        }
        .navigationTitle("Nouvel entretien")
        .alert("Entretien enregistré !", isPresented: $showAlert) {
            Button("OK") {
                // 👋 Fermer la vue après confirmation
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Un rappel vous sera envoyé dans 180 jours pour cet entretien.")
        }
    }
}
