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
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Firebase yapılandırması
        FirebaseApp.configure()
        
        // Uygulama açıldığında temayı uygula
        ThemeManager.shared.applyTheme(theme: ThemeManager.shared.currentTheme)

        // Arka plan görevini kaydet
        registerBackgroundTasks()

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
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


//var ENV: APIKeyable {
//    return ProdENV()
//}
