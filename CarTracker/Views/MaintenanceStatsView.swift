import SwiftUI
import Charts
import PDFKit

struct MaintenanceStatsView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    @State private var selectedVehicle: Vehicle? = nil
    @State private var pdfURL: URL? = nil

    struct MonthlyMaintenance: Identifiable {
        var id: String { month }
        var month: String
        var count: Int
    }

    struct MonthlyCost: Identifiable {
        var id: String { month }
        var month: String
        var totalCost: Double
    }

    var filteredRecords: [MaintenanceEntry] {
        selectedVehicle?.maintenanceRecords ?? viewModel.vehicles.flatMap { $0.maintenanceRecords }
    }

    var monthlyData: [MonthlyMaintenance] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let grouped = Dictionary(grouping: filteredRecords) { formatter.string(from: $0.date) }
        return grouped.map { (month, records) in
            MonthlyMaintenance(month: month, count: records.count)
        }.sorted { $0.month < $1.month }
    }

    var monthlyCosts: [MonthlyCost] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let grouped = Dictionary(grouping: filteredRecords) { formatter.string(from: $0.date) }
        return grouped.map { (month, records) in
            MonthlyCost(month: month, totalCost: records.reduce(0) { $0 + $1.cost })
        }.sorted { $0.month < $1.month }
    }

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Entretiens par mois")
                            .font(.title2).bold()
                            .padding(.horizontal)

                        Picker("Véhicule", selection: $selectedVehicle) {
                            Text("Tous les véhicules").tag(nil as Vehicle?)
                            ForEach(viewModel.vehicles) { vehicle in
                                Text(vehicle.name).tag(vehicle as Vehicle?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)

                        Text("Total : \(filteredRecords.count) entretiens")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        if monthlyData.isEmpty {
                            VStack(spacing: 10) {
                                Text("Aucun entretien à afficher")
                                    .foregroundColor(.secondary)
                                Image(systemName: "wrench.and.screwdriver")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 50)
                        } else {
                            Chart(monthlyData) { item in
                                BarMark(
                                    x: .value("Mois", item.month),
                                    y: .value("Nombre", item.count)
                                )
                                .foregroundStyle(.blue)
                            }
                            .frame(height: 200)
                            .padding(.horizontal)

                            Divider().padding(.horizontal)

                            Text("Coûts totaux par mois")
                                .font(.title3).fontWeight(.semibold)
                                .padding(.horizontal)

                            Chart(monthlyCosts) { item in
                                LineMark(
                                    x: .value("Mois", item.month),
                                    y: .value("€", item.totalCost)
                                )
                                .foregroundStyle(.green)
                                .symbol(Circle())
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                        }

                        // 🔒 Bouton partager PDF (auto-génération)
                        if isPremiumUser, let pdfURL {
                            ShareLink(item: pdfURL) {
                                Label("Partager le PDF", systemImage: "square.and.arrow.up")
                                    .font(.callout)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top)
                    .onAppear {
                        if isPremiumUser {
                            exportPDF()
                        }
                    }
                }
                .navigationTitle("Statistiques")
            } else {
                VStack {
                    Text("Statistiques non disponibles")
                        .font(.title2).bold()
                    Text("Requiert iOS 16 ou plus.")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }

    func exportPDF() {
        let pdfMetaData = [
            kCGPDFContextCreator: "CarTracker",
            kCGPDFContextAuthor: "youAllergie",
            kCGPDFContextTitle: "Statistiques d'entretien"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Statistiques_Entretien_Complet.pdf")

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                var yOffset: CGFloat = 50

                // Titre principal
                let title = "Statistiques d’entretien"
                title.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 22)])
                yOffset += 40

                // Nom du véhicule
                if let vehicle = selectedVehicle {
                    let vehicleTitle = "Véhicule : \(vehicle.name)"
                    vehicleTitle.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.italicSystemFont(ofSize: 16)])
                    yOffset += 30
                }

                // Résumé mensuel
                let monthlyTitle = "Résumé mensuel"
                monthlyTitle.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
                yOffset += 30

                for (index, entry) in monthlyData.enumerated() {
                    let cost = String(format: "%.2f €", monthlyCosts[safe: index]?.totalCost ?? 0)
                    let line = "\(entry.month): \(entry.count) entretiens – \(cost)"
                    line.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                    yOffset += 22
                }

                yOffset += 30

                // Détail
                let detailTitle = "Détail des entretiens"
                detailTitle.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
                yOffset += 30

                let formatter = DateFormatter()
                formatter.dateStyle = .medium

                for record in filteredRecords.sorted(by: { $0.date < $1.date }) {
                    let date = formatter.string(from: record.date)
                    let detailLine = "• \(date) — \(record.type) — \(record.mileage) km — \(String(format: "%.2f €", record.cost))"
                    detailLine.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 13)])
                    yOffset += 20
                    if yOffset > pageHeight - 60 {
                        context.beginPage()
                        yOffset = 50
                    }
                }
            }

            self.pdfURL = url
        } catch {
            print("❌ Erreur PDF : \(error.localizedDescription)")
        }
    }
}

// Extension sécurisée
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
