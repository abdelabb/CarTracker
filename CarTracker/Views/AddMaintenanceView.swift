import SwiftUI

struct AddMaintenanceView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vehicle: Vehicle
    var viewModel: VehicleViewModel
    var existingEntry: MaintenanceEntry?

    @State private var type: String = ""
    @State private var mileage: String = ""
    @State private var cost: String = ""
    @State private var notes: String = ""
    @State private var registration: String = ""
    @State private var registrationValid: Bool = true
    @State private var showAlert: Bool = false
    @State private var reminderDate: Date = Calendar.current.date(byAdding: .day, value: 180, to: Date()) ?? Date()

    var isEditing: Bool { existingEntry != nil }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("PrimaryBackground"), Color("SecondaryBackground")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text(isEditing ? "Modifier l'entretien" : "Nouvel entretien")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .padding(.top, 30)

                    VStack(spacing: 16) {
                        field(icon: "wrench.and.screwdriver", content: {
                            TextField("Ex : Vidange, Freins…", text: $type)
                        })

                        field(icon: "calendar.badge.plus", content: {
                            VStack(alignment: .leading, spacing: 4) {
                                DatePicker("Date de rappel personnalisé", selection: $reminderDate, in: Date()..., displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)

                                Text("📬 Une notification vous sera envoyée à cette date.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        })

                        field(icon: "speedometer", content: {
                            TextField("Kilométrage", text: $mileage)
                                .keyboardType(.numberPad)
                        })

                        field(icon: "car.fill", content: {
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("AA-123-AA", text: $registration)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled(true)
                                    .keyboardType(.asciiCapable)
                                    .onChange(of: registration) { newValue in
                                        let formatted = newValue.uppercased().replacingOccurrences(of: " ", with: "")
                                        if formatted != newValue {
                                            registration = formatted
                                        }
                                        let pattern = #"^[A-Z]{2}-\d{3}-[A-Z]{2}$"#
                                        registrationValid = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: formatted)
                                    }
                                    .foregroundColor(registration.isEmpty || registrationValid ? .primary : .red)

                                if !registration.isEmpty && !registrationValid {
                                    Text("Format attendu : AA-123-AA")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                        })

                        field(icon: "eurosign.circle", content: {
                            TextField("Coût (€)", text: $cost)
                                .keyboardType(.decimalPad)
                        })

                        field(icon: "note.text", content: {
                            if #available(iOS 16.0, *) {
                                TextField("Remarques", text: $notes, axis: .vertical)
                            } else {
                                TextField("Remarques", text: $notes)
                            }
                        })
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(radius: 6)

                    // BOUTON ENREGISTRER
                    Button(action: saveEntry) {
                        Label(isEditing ? "Modifier" : "Enregistrer", systemImage: isEditing ? "pencil.circle.fill" : "checkmark.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(registrationValid && !registration.isEmpty ? Color.accentColor : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(!registrationValid || registration.isEmpty)

                    if isEditing {
                        Button(role: .destructive, action: deleteEntry) {
                            Label("Supprimer cet entretien", systemImage: "trash")
                        }
                        .padding(.top, 10)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            if let entry = existingEntry {
                type = entry.type
                reminderDate = Calendar.current.date(byAdding: .day, value: 180, to: entry.date) ?? entry.date
                mileage = String(entry.mileage)
                cost = String(entry.cost)
                notes = entry.notes
                registration = vehicle.registration
            }
        }
        .alert(isEditing ? "Entretien modifié !" : "Entretien enregistré !", isPresented: $showAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Un rappel vous sera envoyé le \(reminderDate.formatted(date: .abbreviated, time: .omitted)).")
        }
    }

    @ViewBuilder
    func field<Content: View>(icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .padding(.top, 6)
            content()
                .textFieldStyle(.roundedBorder)
        }
    }

    private func saveEntry() {
        guard registrationValid else { return }

        let newEntry = MaintenanceEntry(
            type: type,
            date: Date(), // Date automatique à aujourd’hui
            mileage: Int(mileage) ?? 0,
            cost: Double(cost) ?? 0.0,
            notes: notes
        )

        if isEditing, let idx = vehicle.maintenanceRecords.firstIndex(where: { $0.id == existingEntry!.id }) {
            vehicle.maintenanceRecords[idx] = newEntry
        } else {
            vehicle.maintenanceRecords.append(newEntry)
            NotificationManager.shared.scheduleNotification(for: vehicle.name, type: type, on: reminderDate)
        }

        viewModel.saveVehicles()
        showAlert = true
    }

    private func deleteEntry() {
        guard let entry = existingEntry else { return }
        if let index = vehicle.maintenanceRecords.firstIndex(where: { $0.id == entry.id }) {
            vehicle.maintenanceRecords.remove(at: index)
            viewModel.saveVehicles()
            presentationMode.wrappedValue.dismiss()
        }
    }
}
