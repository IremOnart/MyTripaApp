//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 2.01.2025.
//

import SwiftUI
import CoreData
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleTripNotifications(tripId: UUID, tripName: String, startDate: Date, endDate: Date) {
        // Seyahat başlangıç bildirimi içeriği
        let startContent = UNMutableNotificationContent()
        startContent.launchImageName = "appicon2"
        startContent.title = "Seyahat Başlıyor"
        startContent.body = "\(tripName) seyahatiniz başlıyor!"
        startContent.sound = .default
        
        // Seyahat bitiş bildirimi içeriği
        let endContent = UNMutableNotificationContent()
        endContent.launchImageName = "appicon2"
        endContent.title = "Seyahat Bitiyor"
        endContent.body = "\(tripName) seyahatiniz sona eriyor!"
        endContent.sound = .default
        
        // App ikonunu bildirimde eklemek için attachment oluştur
        if let imageURL = Bundle.main.url(forResource: "appicon2", withExtension: "png") {
            do {
                let startAttachment = try UNNotificationAttachment(identifier: "startImageAttachment", url: imageURL, options: nil)
                startContent.attachments = [startAttachment]
                
                let endAttachment = try UNNotificationAttachment(identifier: "endImageAttachment", url: imageURL, options: nil)
                endContent.attachments = [endAttachment]
            } catch {
                print("Error creating attachment: \(error)")
            }
        }
        
        // Tam tarih ve saat için bileşenleri al
        let startComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
        let endComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: endDate)
        
        // Bildirim tetikleyicileri
        let startTrigger = UNCalendarNotificationTrigger(dateMatching: startComponents, repeats: false)
        let endTrigger = UNCalendarNotificationTrigger(dateMatching: endComponents, repeats: false)
        
        // Seyahat başlangıcı için bildirim isteği
        let startRequest = UNNotificationRequest(
            identifier: "trip-start-\(tripId.uuidString)",
            content: startContent,
            trigger: startTrigger
        )
        
        // Seyahat bitişi için bildirim isteği
        let endRequest = UNNotificationRequest(
            identifier: "trip-end-\(tripId.uuidString)",
            content: endContent,
            trigger: endTrigger
        )
        
        // Bildirimleri ekle
        UNUserNotificationCenter.current().add(startRequest) { (error) in
            if let error = error {
                print("Seyahat başlama bildirimi eklenemedi: \(error)")
            }
        }
        
        UNUserNotificationCenter.current().add(endRequest) { (error) in
            if let error = error {
                print("Seyahat bitiş bildirimi eklenemedi: \(error)")
            }
        }

        // Uygulama aktifken de bildirim göstermeyi sağlamak için
//        if UIApplication.shared.applicationState == .active {
//            // Seyahat başladığında, hemen bir popup göstermek
//            showCustomAlert(title: "Seyahat Başlıyor", message: "\(tripName) seyahatiniz başlıyor!")
//        }
    }

    // Uygulama açıkken kullanıcıya bir alert göster
//    func showCustomAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
//        
//        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
//            rootViewController.present(alert, animated: true, completion: nil)
//        }
//    }


}
