import Foundation
import Combine

class Vehicle: ObservableObject, Identifiable, Codable {
    var id: UUID
    var name: String
    var brand: String
    var registration: String

    @Published var entries: [Entry]
    @Published var maintenanceRecords: [MaintenanceEntry]

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

    // Encoder manuellement les propriétés publiées
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(brand, forKey: .brand)
        try container.encode(registration, forKey: .registration)
        try container.encode(entries, forKey: .entries)
        try container.encode(maintenanceRecords, forKey: .maintenanceRecords)
    }

    // Decoder manuellement les propriétés publiées
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        brand = try container.decode(String.self, forKey: .brand)
        registration = try container.decode(String.self, forKey: .registration)
        entries = try container.decode([Entry].self, forKey: .entries)
        maintenanceRecords = try container.decode([MaintenanceEntry].self, forKey: .maintenanceRecords)
    }
}
