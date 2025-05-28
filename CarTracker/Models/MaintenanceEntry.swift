import Foundation

struct MaintenanceEntry: Identifiable, Codable {
    var id = UUID()
    var type: String
    var date: Date
    var mileage: Int
    var cost: Double
    var notes: String
}
