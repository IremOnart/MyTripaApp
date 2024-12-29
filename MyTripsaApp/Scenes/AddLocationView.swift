//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 27.12.2024.
//

import SwiftUI
import MapKit
import CoreLocation

import SwiftUI
import MapKit
import CoreLocation

struct AddLocationView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Varsayılan konum (San Francisco)
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedDate: Date = Date() // Kullanıcı tarafından seçilen tarih
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var userTrackingMode: MapUserTrackingMode = .follow

    var body: some View {
        ScrollView {  // ScrollView ekleniyor
            VStack {
                // Seyahat Adı ve Açıklaması
                TextField("Konum Adı", text: $name)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Açıklama", text: $description)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Tarih Seçici
                DatePicker("Tarih Seç", selection: $selectedDate, displayedComponents: .date)
                    .padding()
                    .datePickerStyle(WheelDatePickerStyle()) // Tarih seçimi için stil

                // Harita Görünümü
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $userTrackingMode)
                    .frame(height: 300)
                    .onTapGesture {
                        let tappedLocation = region.center // Tıklanan koordinatlar region'dan alınır
                        region.center = tappedLocation // Region'un merkezini güncelle
                        selectedLocation = tappedLocation // Seçilen konumu güncelle
                    }
                    .padding()
                
                if let selectedLocation = selectedLocation {
                    Text("Seçilen Konum: \(selectedLocation.latitude), \(selectedLocation.longitude)")
                        .padding()
                }

                Button("Konumu Kaydet") {
                    if let selectedLocation = selectedLocation {
                        // Konumu kaydetme işlemi yapılacak
                        print("Konum kaydedildi: \(selectedLocation.latitude), \(selectedLocation.longitude)")
                    }
                    saveLocation()
                }
                .padding()
            }
            .navigationBarTitle("Konum Ekle")
        }
    }

    // Konumu CoreData'ya kaydetme
    func saveLocation() {
        guard let selectedLocation = selectedLocation else {
            print("Konum seçilmedi!")
            return
        }

        let newLocation = LocationEntity(context: viewContext)
        newLocation.name = name
        newLocation.descriptionText = description
        newLocation.latitude = selectedLocation.latitude
        newLocation.longitude = selectedLocation.longitude
        newLocation.date = selectedDate // Tarih bilgisi kaydediliyor

        do {
            try viewContext.save()
            print("Konum başarıyla kaydedildi.")
        } catch {
            print("Konum kaydedilemedi: \(error.localizedDescription)")
        }
    }
}


