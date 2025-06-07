import StoreKit
import SwiftUI

struct UpgradeView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var viewModel: VehicleViewModel
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false

    var body: some View {
        // 🔒 Si l'utilisateur est premium, on ne montre pas la bannière
        if isPremiumUser {
            EmptyView()
        } else {
            VStack(spacing: 6) {
                if let product = storeManager.products.first {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.yellow)
                                .padding(3)
                                .background(Color.yellow.opacity(0.15))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 0) {
                                Text("Premium Plus")
                                    .font(.footnote)
                                    .fontWeight(.semibold)

                                Text(product.displayPrice)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Label("Plusieurs véhicules", systemImage: "checkmark.circle.fill")
                            Label("Historique illimité", systemImage: "checkmark.circle.fill")
                            Label("Sauvegarde iCloud", systemImage: "checkmark.circle.fill")
                            Label("Graphiques & rappels", systemImage: "checkmark.circle.fill")
                            Label("Sans publicité", systemImage: "checkmark.circle.fill")
                        }
                        .font(.caption2)
                        .foregroundColor(.primary)
                        .labelStyle(.titleOnly)

                        Button(action: {
                            Task {
                                await storeManager.purchase(product)
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "cart")
                                Text("S’abonner")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }

                        Text("Débloquez toutes les fonctionnalités")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 2)
                    }
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                    .padding(.horizontal)
                } else {
                    ProgressView("Chargement…")
                        .padding(6)
                }
            }
            .navigationTitle("Abonnement")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
