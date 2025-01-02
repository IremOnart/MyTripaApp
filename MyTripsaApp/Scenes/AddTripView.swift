//
//  AddTripView.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 15.12.2024.
//

import SwiftUI
import CoreData
import UserNotifications

struct AddTripView: View {
    @State private var tripName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var showAlert: Bool = false
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Yeni Seyahat Ekle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Form {
                    Section(header: Text("Seyahat Bilgileri")) {
                        TextField("Seyahat Adı", text: $tripName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        // Başlangıç tarihi ve saati
                        DatePicker("Başlangıç Tarihi",
                                   selection: $startDate,
                                   displayedComponents: .date).environment(\.timeZone, TimeZone.current)
                        
                        DatePicker("Başlangıç Saati",
                                   selection: $startTime,
                                   displayedComponents: .hourAndMinute).environment(\.timeZone, TimeZone.current)
                        
                        // Bitiş tarihi ve saati
                        DatePicker("Bitiş Tarihi",
                                   selection: $endDate,
                                   displayedComponents: .date).environment(\.timeZone, TimeZone.current)
                        
                        DatePicker("Bitiş Saati",
                                   selection: $endTime,
                                   displayedComponents: .hourAndMinute).environment(\.timeZone, TimeZone.current)
                    }
                    
                    // Mevcut görsel seçici bölümü aynı kalacak
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
                .frame(maxHeight: 500)
                
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
                    Alert(title: Text("Hata"),
                          message: Text("Seyahat adı boş olamaz."),
                          dismissButton: .default(Text("Tamam")))
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func saveTrip() {
        guard !tripName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert = true
            return
        }
        
        // Tarih ve saati birleştir
        let startDateTime = combineDateAndTime(date: startDate, time: startTime)
        let endDateTime = combineDateAndTime(date: endDate, time: endTime)
        
        // Kaydedilen tarihleri kontrol et
        print("Kaydedilen başlangıç tarihi ve saati: \(startDateTime)")
        print("Kaydedilen bitiş tarihi ve saati: \(endDateTime)")
        
        let newTrip = TripEntity(context: managedObjectContext)
        let tripId = UUID()
        newTrip.id = tripId
        newTrip.name = tripName
        newTrip.startDate = startDateTime
        newTrip.endDate = endDateTime
        
        if let selectedImage = selectedImage {
            let imageName = "\(UUID().uuidString).png"
            if let savedImageName = saveImageToDocumentsDirectory(image: selectedImage, imageName: imageName) {
                newTrip.image = savedImageName
            }
        }
        
        do {
            try managedObjectContext.save()
            // Bildirimleri planla
            notificationManager.scheduleTripNotifications(
                tripId: tripId,
                tripName: tripName,
                startDate: startDateTime,
                endDate: endDateTime
            )
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save trip: \(error.localizedDescription)")
        }
    }
    
    // Tarih ve saati birleştiren yardımcı fonksiyon
    func combineDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current

        // Kullanıcının yerel saat diliminden tarih bileşenlerini al
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        // Zaman bileşenlerini tarih bileşenleriyle birleştir
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute

        // Yerel saat diliminde Date nesnesi oluştur
        if let combinedDate = calendar.date(from: combinedComponents) {
            return combinedDate // Yerel saatte döndür
        } else {
            fatalError("Tarih birleştirilemedi.")
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
}


