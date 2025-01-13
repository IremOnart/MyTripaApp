//
//  AppDelegate.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 16.12.2024.
//
import SwiftUI
import FirebaseCore
import Firebase
import GoogleSignIn
import BackgroundTasks
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Firebase yapılandırması
        FirebaseApp.configure()
        
        // Uygulama açıldığında temayı uygula
        ThemeManager.shared.applyTheme(theme: ThemeManager.shared.currentTheme)
        
        // Arka plan görevini kaydet
        registerBackgroundTasks()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Bildirim izni verildi.")
            } else {
                print("Bildirim izni verilmedi.")
            }
        }
        
        // UNUserNotificationCenter delegate'ini atama
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func scheduleTripNotifications(tripId: UUID, tripName: String, startDate: Date, endDate: Date) {
        let startContent = UNMutableNotificationContent()
        startContent.title = "Seyahat Başlıyor"
        startContent.body = "\(tripName) seyahatiniz başlıyor!"
        startContent.sound = .default
        startContent.launchImageName = "appicon2"
        
        let endContent = UNMutableNotificationContent()
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
        
        // Başlangıç ve bitiş tarihinden dateComponents oluştur
        let startComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
        let endComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: endDate)
        
        // Bildirim tetikleyicileri oluştur
        let startTrigger = UNCalendarNotificationTrigger(dateMatching: startComponents, repeats: false)
        let endTrigger = UNCalendarNotificationTrigger(dateMatching: endComponents, repeats: false)
        
        // Bildirim taleplerini oluştur
        let startRequest = UNNotificationRequest(
            identifier: "trip-start-\(tripId.uuidString)",
            content: startContent,
            trigger: startTrigger
        )
        
        let endRequest = UNNotificationRequest(
            identifier: "trip-end-\(tripId.uuidString)",
            content: endContent,
            trigger: endTrigger
        )
        
        // Bildirimleri ekle
        UNUserNotificationCenter.current().add(startRequest) { error in
            if let error = error {
                print("Error adding start notification: \(error)")
            }
        }
        
        UNUserNotificationCenter.current().add(endRequest) { error in
            if let error = error {
                print("Error adding end notification: \(error)")
            }
        }
    }
    
    // Bildirim aktifken gösterilecek işlemler (üzerine tıklanmışsa)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Bildirim tıklandı: \(response.notification.request.content.title)")
        // Seyahat tarihi geldiğinde NotificationCenter'a bildirim gönder
        if response.notification.request.content.title == "Seyahat Başlıyor" {
            NotificationCenter.default.post(name: .travelDateArrived, object: nil)
        }
        completionHandler()
    }
    
    // Uygulama aktifken bildirimler geldiğinde yukarıdan gösterilsin
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Bildirim geldi: \(notification.request.content.title)")
        
        // Seyahat tarihi geldiğinde NotificationCenter'a bildirim gönder
        if notification.request.content.title == "Seyahat Başlıyor" {
            NotificationCenter.default.post(name: .travelDateArrived, object: nil)
        }
        completionHandler([.banner, .sound])
    }
    
    private func registerBackgroundTasks() {
        // Arka plan görevini kaydet
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.myapp.refresh", using: nil) { task in
            // Arka plan görevi başladığında yapılacak işlem
            self.handleBackgroundTask(task as! BGAppRefreshTask)
        }
    }
    
    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        // Arka plan görevini işleme al
        task.expirationHandler = {
            // Görev sona erdiğinde yapılacak işler
        }
        
        // Burada arka planda yapılacak işlemi tanımlayın (örneğin bildirim gönderme vs.)
        
        // Arka plan görevini tamamla
        task.setTaskCompleted(success: true)
    }
}


