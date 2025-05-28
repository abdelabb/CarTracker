import Foundation

class Vehicle: ObservableObject, Identifiable, Codable {
    var id: UUID
    var name: String
    var brand: String
    var registration: String

    // Ne pas mettre @Published ici (inutile pour UserDefaults)
    var entries: [Entry]
    var maintenanceRecords: [MaintenanceEntry]

    enum CodingKeys: CodingKey {
        case id, name, brand, registration, entries, maintenanceRecords
    }

    init(id: UUID = UUID(), name: String, brand: String, registration: String, entries: [Entry] = [], maintenanceRecords: [MaintenanceEntry] = []) {
        self.id = id
        self.name = name
        self.brand = brand
        self.registration = registration
        self.entries = entries
        self.maintenanceRecords = maintenanceRecords
    }

    // Encodage
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(brand, forKey: .brand)
        try container.encode(registration, forKey: .registration)
        try container.encode(entries, forKey: .entries)
        try container.encode(maintenanceRecords, forKey: .maintenanceRecords)
    }

    // Décodage
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        brand = try container.decode(String.self, forKey: .brand)
        registration = try container.decode(String.self, forKey: .registration)
        entries = try container.decode([Entry].self, forKey: .entries)
        maintenanceRecords = try container.decode([MaintenanceEntry].self, forKey: .maintenanceRecords)
    }

    // Exemple statique pour test
    static let example = Vehicle(
        name: "Peugeot 208",
        brand: "Peugeot",
        registration: "AB-123-CD",
        maintenanceRecords: [
            MaintenanceEntry(type: "Vidange", date: Date(), mileage: 120000, cost: 89.99, notes: "Changement d’huile"),
            MaintenanceEntry(type: "Freins", date: Date(), mileage: 118500, cost: 120.00, notes: "Plaquettes avant changées"),
            MaintenanceEntry(type: "Contrôle technique", date: Date(), mileage: 122000, cost: 65.00, notes: "OK, validé 2 ans")
        ]
    )
}
