import SwiftUI

struct AddVehicleView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: VehicleViewModel

    @State private var name = ""
    @State private var brand = ""
    @State private var registration = ""
    @State private var registrationValid = true

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("PrimaryBackground"), Color("SecondaryBackground")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Nouveau véhicule")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .padding(.top, 30)

                VStack(spacing: 16) {
                    vehicleField(icon: "car.fill") {
                        TextField("Nom du véhicule", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }

                    vehicleField(icon: "building.2.fill") {
                        TextField("Marque", text: $brand)
                            .textFieldStyle(.roundedBorder)
                    }

                    vehicleField(icon: "number.circle.fill") {
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Immatriculation (AA-123-AA)", text: $registration)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled(true)
                                .keyboardType(.asciiCapable)
                                .onChange(of: registration) { newValue in
                                    let formatted = newValue.uppercased().replacingOccurrences(of: " ", with: "")
                                    if formatted != newValue {
                                        registration = formatted
                                    }
                                    let pattern = #"^[A-Z]{2}-\d{3}-[A-Z]{2}$"#
                                    let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
                                    registrationValid = predicate.evaluate(with: formatted)
                                }
                                .foregroundColor(registration.isEmpty || registrationValid ? .primary : .red)

                            if !registration.isEmpty && !registrationValid {
                                Text("Format invalide. Exemple : AB-123-CD")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(radius: 6)

                // ✅ BOUTON
                Button(action: addVehicle) {
                    Label("Ajouter", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(validForm ? Color.accentColor : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(!validForm)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
    }

    // 💡 Mise en page champ avec icône
    @ViewBuilder
    func vehicleField<Content: View>(icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .padding(.top, 6)
            content()
        }
    }

    var validForm: Bool {
        !name.isEmpty && !brand.isEmpty && registrationValid && !registration.isEmpty
    }

    func addVehicle() {
        let newVehicle = Vehicle(name: name, brand: brand, registration: registration)
        viewModel.addVehicle(newVehicle)
        presentationMode.wrappedValue.dismiss()
    }
}
