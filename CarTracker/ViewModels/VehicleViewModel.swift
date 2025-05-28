// CarTracker/ViewModels/VehicleViewModel.swift

import Foundation

class VehicleViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = [] {
        didSet {
            saveVehicles()
        }
    }

    private let saveKey = "SavedVehicles"

    init() {
        loadVehicles()
    }

    // Sauvegarder dans UserDefaults
    private func saveVehicles() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(vehicles) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    // Sauvegarder manuellement (accessible depuis une vue)
    func save() {
        saveVehicles()
    }

    // Charger depuis UserDefaults
    private func loadVehicles() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Vehicle].self, from: savedData) {
                self.vehicles = decoded
            }
        }
    }

    // Ajouter un véhicule
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }
}
