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

    func saveVehicles() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(vehicles) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadVehicles() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Vehicle].self, from: savedData) {
                self.vehicles = decoded
            }
        }
    }

    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }
}
