//
//  NotificationManager.swift
//  CarTracker
//
//  Created by abbas on 27/05/2025.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func scheduleNotification(for vehicleName: String, type: String, on date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Entretien à venir pour \(vehicleName)"
        content.body = "Un rappel pour le type d'entretien : \(type)"
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur de notification : \(error.localizedDescription)")
            } else {
                print("Notification planifiée pour \(vehicleName)")
            }
        }
    }
}
