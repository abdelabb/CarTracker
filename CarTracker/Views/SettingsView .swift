import StoreKit
import SwiftUI

struct UpgradeView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var viewModel: VehicleViewModel

    var body: some View {
        VStack(spacing: 8) {
            if let product = storeManager.products.first {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.yellow)
                            .padding(4)
                            .background(Color.yellow.opacity(0.15))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Premium Plus")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(product.displayPrice)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 2) {
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
                        HStack {
                            Image(systemName: "cart")
                            Text("S’abonner")
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }

                    Text("Débloquez toutes les fonctionnalités")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 2)
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
                .padding(.horizontal)
            } else {
                ProgressView("Chargement...")
                    .padding(8)
            }
        }
        .navigationTitle("Abonnement")
        .navigationBarTitleDisplayMode(.inline)
    }
}
