import Foundation

struct MaintenanceEntry: Identifiable, Codable {
    var id = UUID()
    var type: String
    var date: Date
    var mileage: Int
    var cost: Double
    var notes: String
    
    init(id: UUID = UUID(), type: String, date: Date, mileage: Int, cost: Double, notes: String) {
          self.id = id
          self.type = type
          self.date = date
          self.mileage = mileage
          self.cost = cost
          self.notes = notes
      }
}
