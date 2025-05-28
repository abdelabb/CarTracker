//
//  Entry.swift
//  CarTracker
//
//  Created by abbas on 27/05/2025.
//

// Models/Entry.swift

import Foundation

enum EntryType: String, Codable, CaseIterable {
    case fuel = "Carburant"
    case maintenance = "Entretien"
    case invoice = "Facture"
    case other = "Autre"
}

struct Entry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var type: EntryType
    var note: String
    var cost: Double
}
