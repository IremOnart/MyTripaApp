//
//  AddTripView.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 15.12.2024.
//

import SwiftUI
import CoreData
import UserNotifications
import BackgroundTasks

struct AddTripView: View {
    @State private var tripName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @Binding var trips: [Trip] // Binding to pass trips back to the parent view
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext // Core Data Context
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var showAlert: Bool = false // Alert kontrolü için
    
    var body: some View {
        NavigationView {
            VStack() {
                // Title
                Text("Yeni Seyahat Ekle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Form
                Form {
                    Section(header: Text("Seyahat Bilgileri")) {
                        TextField("Seyahat Adı", text: $tripName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        DatePicker("Başlangıç Tarihi", selection: $startDate, displayedComponents: .date)
                        
                        DatePicker("Bitiş Tarihi", selection: $endDate, displayedComponents: .date)
                    }
                    
                    Section(header: Text("Görsel")) {
                        VStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(10)
                            } else {
                                Text("Bir görsel seçin")
                                    .foregroundColor(.gray)
                                    .frame(height: 150)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                isImagePickerPresented.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("Görsel Seç")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImagePicker(didSelectImage: { image in
                                selectedImage = image
                            }, isImagePickerPresented: $isImagePickerPresented)
                        }
                    }
                }
                .frame(maxHeight: 500) // Sınırlı alan
                
                // Save Button
                Button(action: {
                    saveTrip()
                }) {
                    Text("Kaydet")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Hata"), message: Text("Seyahat adı boş olamaz."), dismissButton: .default(Text("Tamam")))
                }
            }
            .padding(.horizontal)
            .onAppear {
                requestNotificationPermission()
                scheduleBackgroundTask()
            }
        }
    }
    
    private func saveTrip() {
        // Eğer seyahat adı boşsa, uyarı göster ve kaydetme
        guard !tripName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert = true
            return
        }

        let newTrip = TripEntity(context: managedObjectContext)
        newTrip.id = UUID()
        newTrip.name = tripName
        newTrip.startDate = startDate
        newTrip.endDate = endDate

        if let selectedImage = selectedImage {
            let imageName = "\(UUID().uuidString).png"
            if let savedImageName = saveImageToDocumentsDirectory(image: selectedImage, imageName: imageName) {
                newTrip.image = savedImageName
            }
        }

        do {
            try managedObjectContext.save()
            
            // Seyahati kaydettikten sonra bildirim gönderme
            scheduleNotification(for: newTrip)
            
            // Arka plan görevini planla
            scheduleBackgroundTask()

            presentationMode.wrappedValue.dismiss() // Kaydedildikten sonra önceki ekrana yönlendirme
        } catch {
            print("Failed to save trip: \(error.localizedDescription)")
        }
    }

    private func saveImageToDocumentsDirectory(image: UIImage, imageName: String) -> String? {
        guard let data = image.pngData() else { return nil }

        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(imageName)

        do {
            try data.write(to: fileURL)
            return fileURL.lastPathComponent
        } catch {
            print("Hata: Görsel kaydedilemedi. \(error.localizedDescription)")
            return nil
        }
    }
    
    // Arka plan görevi için bildirim izni isteme
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Bildirim izni verildi.")
            } else {
                print("Bildirim izni reddedildi.")
            }
        }
    }
    
    // Arka plan görevi kaydetme
    func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.myapp.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 saat sonra çalıştır
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Arka plan görevi planlanamadı: \(error.localizedDescription)")
        }
    }
    
    // Seyahat için bildirim gönderme
    func scheduleNotification(for trip: TripEntity) {
        let content = UNMutableNotificationContent()
        content.title = "Seyahat Hatırlatması"
        content.body = "Seyahatiniz \(trip.name ?? "isimlendirilmemiş") başlıyor!"
        content.sound = .default

        guard let startDate = trip.startDate else { return }

        // Seyahatin başlangıç tarihinden 1 gün önce bir bildirim planla
        let notificationDate = Calendar.current.date(byAdding: .day, value: -1, to: startDate)
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: trip.id?.uuidString ?? UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim planlanırken hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    // Arka plan görevi için yapılacak işlemler
    func handleBackgroundTask(_ task: BGAppRefreshTask) {
        task.expirationHandler = {
            // Görev zaman aşımına uğrarsa yapılacaklar
        }

        // Seyahatleri kontrol et ve gerekirse bildirimleri planla
        scheduleNotificationsForUpcomingTrips()

        task.setTaskCompleted(success: true)
    }

    // Seyahatler için bildirimleri planlama
    func scheduleNotificationsForUpcomingTrips() {
        let trips = fetchTrips() // CoreData'dan seyahatleri al
        
        for trip in trips {
            scheduleNotification(for: trip) // Her bir seyahat için bildirim planla
        }
    }
    
    // Seyahatleri CoreData'dan almak
    func fetchTrips() -> [TripEntity] {
        let fetchRequest: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        
        do {
            let trips = try managedObjectContext.fetch(fetchRequest)
            return trips
        } catch {
            print("Seyahatler alınırken hata oluştu: \(error.localizedDescription)")
            return []
        }
    }
}

