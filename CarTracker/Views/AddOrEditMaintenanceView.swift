import SwiftUI

struct AddOrEditMaintenanceView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var vehicle: Vehicle
    var viewModel: VehicleViewModel
    var existingEntry: MaintenanceEntry?

    @State private var type: String
    @State private var date: Date
    @State private var mileage: String
    @State private var cost: String
    @State private var notes: String
    @State private var showAlert = false

    var isEditing: Bool { existingEntry != nil }

    init(vehicle: Vehicle, viewModel: VehicleViewModel, existingEntry: MaintenanceEntry?) {
        self.vehicle = vehicle
        self.viewModel = viewModel
        self.existingEntry = existingEntry

        _type = State(initialValue: existingEntry?.type ?? "")
        _date = State(initialValue: existingEntry?.date ?? Date())
        _mileage = State(initialValue: existingEntry.map { String($0.mileage) } ?? "")
        _cost = State(initialValue: existingEntry.map { String(format: "%.2f", $0.cost) } ?? "")
        _notes = State(initialValue: existingEntry?.notes ?? "")
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("PrimaryBackground"), Color("SecondaryBackground")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer(minLength: 30)

                VStack(spacing: 22) {
                    Text(isEditing ? "Modifier l'entretien" : "Nouvel entretien")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Group {
                        HStack {
                            Image(systemName: "wrench.fill")
                                .foregroundColor(.accentColor)
                            TextField("Type (ex : Vidange)", text: $type)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.accentColor)
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                        }

                        HStack {
                            Image(systemName: "speedometer")
                                .foregroundColor(.accentColor)
                            TextField("Kilométrage", text: $mileage)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack {
                            Image(systemName: "eurosign.circle")
                                .foregroundColor(.accentColor)
                            TextField("Coût (€)", text: $cost)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack(alignment: .top) {
                            Image(systemName: "note.text")
                                .foregroundColor(.accentColor)
                                .padding(.top, 6)
                            if #available(iOS 16.0, *) {
                                TextField("Remarques", text: $notes, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                TextField("Remarques", text: $notes)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }

                    // BOUTON ENREGISTRER
                    Button(action: save) {
                        HStack {
                            Image(systemName: isEditing ? "pencil.circle.fill" : "checkmark.circle.fill")
                            Text(isEditing ? "Modifier" : "Enregistrer")
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [.accentColor, .accentColor.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: .accentColor.opacity(0.2), radius: 6, x: 0, y: 3)
                    }

                    // BOUTON SUPPRIMER
                    if isEditing {
                        Button(role: .destructive, action: deleteEntry) {
                            Label("Supprimer cet entretien", systemImage: "trash")
                                .padding(.top, 10)
                        }
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 16)

                Spacer()
            }
        }
        .alert(isEditing ? "Entretien modifié !" : "Entretien enregistré !", isPresented: $showAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(isEditing ?
                 "Les modifications ont bien été enregistrées." :
                 "Un nouveau rappel sera ajouté pour cet entretien.")
        }
    }

    func save() {
        guard let mileageInt = Int(mileage),
              let costDouble = Double(cost) else {
            return
        }

        if let entry = existingEntry {
            if let index = vehicle.maintenanceRecords.firstIndex(where: { $0.id == entry.id }) {
                vehicle.maintenanceRecords[index].type = type
                vehicle.maintenanceRecords[index].date = date
                vehicle.maintenanceRecords[index].mileage = mileageInt
                vehicle.maintenanceRecords[index].cost = costDouble
                vehicle.maintenanceRecords[index].notes = notes
            }
        } else {
            let newEntry = MaintenanceEntry(type: type, date: date, mileage: mileageInt, cost: costDouble, notes: notes)
            vehicle.maintenanceRecords.append(newEntry)
        }

        viewModel.saveVehicles()
        showAlert = true
    }

    func deleteEntry() {
        guard let entry = existingEntry else { return }
        if let index = vehicle.maintenanceRecords.firstIndex(where: { $0.id == entry.id }) {
            vehicle.maintenanceRecords.remove(at: index)
            viewModel.saveVehicles()
            presentationMode.wrappedValue.dismiss()
        }
    }
}
