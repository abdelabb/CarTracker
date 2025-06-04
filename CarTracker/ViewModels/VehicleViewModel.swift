import Foundation
import SwiftUI

class VehicleViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = [] {
        didSet {
            saveVehicles()
        }
    }

    private let saveKey = "SavedVehicles"

    @AppStorage("isPremiumUser") private var isPremiumUser: Bool = false {
        didSet {
            if !isPremiumUser {
                deleteICloudData()
            }
        }
    }

    init() {
        loadVehicles()
        if isPremiumUser {
            restoreFromICloud()
        }
    }

    // MARK: - Sauvegarde locale + iCloud
    func saveVehicles() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(vehicles) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }

        // iCloud (Premium uniquement)
        if isPremiumUser {
            for vehicle in vehicles {
                exportToICloud(vehicle: vehicle)
            }
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

    // MARK: - Ajouter un véhicule
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }

    // MARK: - Exporter vers iCloud
    private func exportToICloud(vehicle: Vehicle) {
        guard let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent("vehicle-\(vehicle.id).json") else { return }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(vehicle)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
            print("✅ iCloud sauvegardé : \(url.lastPathComponent)")
        } catch {
            print("❌ iCloud erreur de sauvegarde : \(error.localizedDescription)")
        }
    }

    // MARK: - Restaurer depuis iCloud
    private func restoreFromICloud() {
        guard let documentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents") else { return }

        DispatchQueue.global(qos: .background).async {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)

                var restored: [Vehicle] = []
                let decoder = JSONDecoder()

                for fileURL in fileURLs where fileURL.pathExtension == "json" {
                    let data = try Data(contentsOf: fileURL)
                    let vehicle = try decoder.decode(Vehicle.self, from: data)
                    restored.append(vehicle)
                }

                DispatchQueue.main.async {
                    self.vehicles = restored
                    print("✅ Véhicules restaurés depuis iCloud.")
                }
            } catch {
                print("❌ Erreur restauration iCloud : \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Supprimer les données iCloud si abonnement terminé
    private func deleteICloudData() {
        guard let documentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents") else {
            print("❌ Impossible d’accéder au dossier iCloud.")
            return
        }

        DispatchQueue.global(qos: .background).async {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)

                for fileURL in fileURLs where fileURL.pathExtension == "json" {
                    try FileManager.default.removeItem(at: fileURL)
                    print("🗑️ Supprimé de iCloud : \(fileURL.lastPathComponent)")
                }

                DispatchQueue.main.async {
                    print("✅ Données iCloud supprimées avec succès.")
                }
            } catch {
                print("❌ Erreur suppression iCloud : \(error.localizedDescription)")
            }
        }
    }
}
