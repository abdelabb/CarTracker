import Foundation
import Combine

class Vehicle: ObservableObject, Identifiable, Codable, Hashable {
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

    // MARK: - Codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(brand, forKey: .brand)
        try container.encode(registration, forKey: .registration)
        try container.encode(entries, forKey: .entries)
        try container.encode(maintenanceRecords, forKey: .maintenanceRecords)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        brand = try container.decode(String.self, forKey: .brand)
        registration = try container.decode(String.self, forKey: .registration)
        entries = try container.decode([Entry].self, forKey: .entries)
        maintenanceRecords = try container.decode([MaintenanceEntry].self, forKey: .maintenanceRecords)
    }

    // MARK: - Hashable
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
