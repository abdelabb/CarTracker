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
                    VStack(alignment: .leading, spacing: 24) {
//                        Text("📊 Statistiques d’entretien")
//                            .font(.title.bold())
//                            .padding(.horizontal)

                        Picker("Véhicule", selection: $selectedVehicle) {
                            Text("Tous les véhicules").tag(nil as Vehicle?)
                            ForEach(viewModel.vehicles) { vehicle in
                                Text(vehicle.name).tag(vehicle as Vehicle?)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        Text("Total : \(filteredRecords.count) entretiens")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        if monthlyData.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "wrench.and.screwdriver")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.3))
                                Text("Aucun entretien à afficher")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 50)
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("🔧 Entretiens par mois")
                                    .font(.title3.bold())
                                    .padding(.horizontal)

                                Chart {
                                    ForEach(monthlyData) { item in
                                        BarMark(
                                            x: .value("Mois", item.month),
                                            y: .value("Entretiens", item.count)
                                        )
                                        .foregroundStyle(.blue.gradient)
                                        .cornerRadius(6)
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(values: .automatic)
                                }
                                .frame(height: 240)
                                .padding(.horizontal)

                                Text("💰 Coûts totaux par mois")
                                    .font(.title3.bold())
                                    .padding(.horizontal)

                                Chart {
                                    ForEach(monthlyCosts) { item in
                                        LineMark(
                                            x: .value("Mois", item.month),
                                            y: .value("€", item.totalCost)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .symbol(Circle())
                                        .foregroundStyle(.green.gradient)
                                    }
                                }
                                .frame(height: 240)
                                .padding(.horizontal)
                            }
                        }

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
                .navigationTitle("📊 Entretiens")
            } else {
                VStack(spacing: 12) {
                    Text("Statistiques non disponibles")
                        .font(.title2.bold())
                    Text("Requiert iOS 16 ou plus.")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }

    private func exportPDF() {
        let pdfMetaData = [
            kCGPDFContextCreator: "CarTracker",
            kCGPDFContextAuthor: "youAllergie",
            kCGPDFContextTitle: "Statistiques d'entretien"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Statistiques_Entretien_Complet.pdf")

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                var yOffset: CGFloat = 50

                "Statistiques d’entretien".draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 22)])
                yOffset += 40

                if let vehicle = selectedVehicle {
                    "Véhicule : \(vehicle.name)".draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.italicSystemFont(ofSize: 16)])
                    yOffset += 30
                }

                "Résumé mensuel".draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
                yOffset += 30

                for (index, entry) in monthlyData.enumerated() {
                    let cost = String(format: "%.2f €", monthlyCosts[safe: index]?.totalCost ?? 0)
                    let line = "\(entry.month): \(entry.count) entretiens – \(cost)"
                    line.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                    yOffset += 22
                }

                yOffset += 30
                "Détail des entretiens".draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
                yOffset += 30

                let formatter = DateFormatter()
                formatter.dateStyle = .medium

                for record in filteredRecords.sorted(by: { $0.date < $1.date }) {
                    let date = formatter.string(from: record.date)
                    let line = "• \(date) — \(record.type) — \(record.mileage) km — \(String(format: "%.2f €", record.cost))"
                    line.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 13)])
                    yOffset += 20
                    if yOffset > pageRect.height - 60 {
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

// Extension sécurisée pour éviter les crashs
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
