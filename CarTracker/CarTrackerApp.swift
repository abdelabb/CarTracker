import UserNotifications
import SwiftUI
import StoreKit

@main
struct CarTrackerApp: App {
    @StateObject var storeManager = StoreManager()
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if success {
                print("Autorisation notifications accordée.")
            } else if let error = error {
                print("Erreur autorisation : \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeManager)
        }
    }
}
