import SwiftUI
import UserNotifications

struct VehicleDetailView: View {
    @ObservedObject var vehicle: Vehicle
    var viewModel: VehicleViewModel

    @State private var maintenanceToEdit: MaintenanceEntry? = nil
    @State private var showEditSheet = false
    @State private var showLimitAlert = false
    @State private var showReminderConfirmation = false

    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Carte véhicule
                HStack(alignment: .center, spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.13))
                            .frame(width: 60, height: 60)
                        Image(systemName: "car.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.accentColor)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vehicle.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Immatriculation : \(vehicle.registration)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 7, x: 0, y: 3)

                // Historique entretiens
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundColor(.accentColor)
                        Text("Entretiens")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }

                    if !vehicle.maintenanceRecords.isEmpty {
                        VStack(spacing: 14) {
                            ForEach(vehicle.maintenanceRecords) { record in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(record.type)
                                            .font(.headline)
                                            .foregroundColor(.accentColor)
                                        Spacer()
                                        Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.footnote)
                                            .foregroundColor(.secondary)

                                        Button(action: {
                                            maintenanceToEdit = record
                                            showEditSheet = true
                                        }) {
                                            Image(systemName: "pencil")
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    HStack {
                                        Image(systemName: "speedometer")
                                            .foregroundColor(.gray)
                                        Text("Km : \(record.mileage)")
                                            .font(.subheadline)
                                    }
                                    HStack {
                                        Image(systemName: "eurosign.circle.fill")
                                            .foregroundColor(.gray)
                                        Text("Coût : \(String(format: "%.2f €", record.cost))")
                                            .font(.subheadline)
                                    }
                                    if !record.notes.isEmpty {
                                        HStack(alignment: .top) {
                                            Image(systemName: "note.text")
                                                .foregroundColor(.gray)
                                            Text("Remarques : \(record.notes)")
                                                .font(.subheadline)
                                        }
                                    }

                                    if isPremiumUser {
                                        Button(action: {
                                            scheduleReminder(for: record)
                                        }) {
                                            Label("📅 Programmer un rappel intelligent", systemImage: "bell.badge.fill")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                                .padding(.top, 6)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground).opacity(0.80))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                            }
                            .onDelete(perform: deleteMaintenance)
                        }
                        .padding(10)
                        .background(Color.accentColor.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    } else {
                        Text("Aucun entretien enregistré.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color(.systemBackground).opacity(0.80))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            .padding([.horizontal, .top])
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("PrimaryBackground"),
                    Color("SecondaryBackground")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Détail véhicule")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if isPremiumUser || vehicle.maintenanceRecords.count < 1 {
                        navigateToAddMaintenance()
                    } else {
                        showLimitAlert = true
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .sheet(item: $maintenanceToEdit) { entry in
            AddOrEditMaintenanceView(
                vehicle: vehicle,
                viewModel: viewModel,
                existingEntry: entry
            )
        }
        .alert("Limite atteinte", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Vous devez passer à la version Premium pour ajouter plus d’un entretien.")
        }
        .alert("Rappel programmé ✅", isPresented: $showReminderConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Un rappel d’entretien sera envoyé dans 6 mois.")
        }
    }

    func navigateToAddMaintenance() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.present(
                UIHostingController(rootView: AddMaintenanceView(vehicle: vehicle, viewModel: viewModel)),
                animated: true
            )
        }
    }

    func deleteMaintenance(at offsets: IndexSet) {
        vehicle.maintenanceRecords.remove(atOffsets: offsets)
        viewModel.saveVehicles()
    }

    // MARK: - Programmation de rappel intelligent
    func scheduleReminder(for record: MaintenanceEntry) {
        let content = UNMutableNotificationContent()
        content.title = "📅 Entretien recommandé"
        content.body = "Un nouvel entretien est conseillé pour \(vehicle.name)."
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .month, value: 6, to: record.date) ?? Date()
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                DispatchQueue.main.async {
                    showReminderConfirmation = true
                }
            } else {
                print("❌ Erreur notification : \(error?.localizedDescription ?? "inconnue")")
            }
        }
    }
}
