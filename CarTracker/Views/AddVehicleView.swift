//
//  AddVehicleView.swift
//  CarTracker
//
//  Created by abbas on 27/05/2025.
//

// Views/AddVehicleView.swift

import SwiftUI

struct AddVehicleView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: VehicleViewModel

    @State private var name = ""
    @State private var brand = ""
    @State private var registration = ""

    var body: some View {
        Form {
            TextField("Nom du véhicule", text: $name)
            TextField("Marque", text: $brand)
            TextField("Immatriculation", text: $registration)

            Button("Ajouter") {
                let vehicle = Vehicle(name: name, brand: brand, registration: registration)
                viewModel.addVehicle(vehicle)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Nouveau véhicule")
    }
}
