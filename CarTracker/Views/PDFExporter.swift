//
//  PDFExporter.swift
//  CarTracker
//
//  Created by abbas on 04/06/2025.
//

import SwiftUI
import PDFKit

class PDFExporter {
    static func generatePDF(from records: [MaintenanceEntry], vehicleName: String?) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "CarTracker",
            kCGPDFContextAuthor: "youAllergie"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 595.2
        let pageHeight = 841.8
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            let title = "Historique des entretiens"
            let vehicle = vehicleName ?? "Tous les véhicules"
            let titleFont = UIFont.boldSystemFont(ofSize: 20)
            let bodyFont = UIFont.systemFont(ofSize: 14)

            var y: CGFloat = 40

            title.draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: titleFont])
            y += 30
            vehicle.draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: bodyFont])
            y += 30

            for record in records {
                let date = DateFormatter.localizedString(from: record.date, dateStyle: .medium, timeStyle: .none)
                let line = "• \(date) — \(record.type) — \(String(format: "%.2f €", record.cost))"
                line.draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: bodyFont])
                y += 20
                if y > pageHeight - 40 {
                    context.beginPage()
                    y = 40
                }
            }
        }

        return data
    }
}
