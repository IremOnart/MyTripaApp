//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 2.01.2025.
//
import SwiftUI
import CoreData
import MapKit

struct LocationDetailsView: View {
    @State var location: LocationEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String
    @State private var description: String
    @State private var selectedDate: Date
    @State private var region: MKCoordinateRegion

    init(location: LocationEntity) {
        self._location = State(initialValue: location)
        self._name = State(initialValue: location.unwrappedName)
        self._description = State(initialValue: location.unwrappedlocationDescription)
        self._selectedDate = State(initialValue: location.unwrappedDate)
        let latitude = location.latitude // Konumun enlemi (Core Data'dan alınacak)
        let longitude = location.longitude // Konumun boylamı (Core Data'dan alınacak)
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    var body: some View {
        Form {
            Section(header: Text("Konum Bilgileri")) {
                TextField("Konum Adı", text: $name)
                TextField("Açıklama", text: $description)
                DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
            }

            Section(header: Text("Konum Haritası")) {
                Map(coordinateRegion: $region, annotationItems: [location]) { _ in
                    MapPin(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), tint: .red)
                }
                .frame(height: 200)
                .cornerRadius(10)
                .onTapGesture {
                    openInMaps()
                }
            }

            Button("Değişiklikleri Kaydet") {
                saveChanges()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Konum Detayları")
    }

    private func saveChanges() {
        var didMakeChanges = false

        // Değişiklik yapıldıysa sadece o alanı güncelle
        if location.name != name {
            location.name = name
            didMakeChanges = true
            print("Konum adı güncellendi: \(name)")
        }
        if location.locationDescription != description {
            location.locationDescription = description
            didMakeChanges = true
            print("Konum açıklaması güncellendi: \(description)")
        }
        if location.date != selectedDate {
            location.date = selectedDate
            didMakeChanges = true
            print("Konum tarihi güncellendi: \(selectedDate)")
        }

        // Eğer herhangi bir değişiklik yapılmadıysa işlemi sonlandır
        guard didMakeChanges else {
            print("Hiçbir değişiklik yapılmadı.")
            presentationMode.wrappedValue.dismiss()
            return
        }

        // Değişiklikler yapıldıysa kaydet
        do {
            try viewContext.save()
//            NotificationCenter.default.post(name: .tripUpdated, object: nil)
            presentationMode.wrappedValue.dismiss()
            print("Değişiklikler başarıyla kaydedildi.")
        } catch let error as NSError {
            print("Değişiklikler kaydedilemedi: \(error), \(error.userInfo)")
        }
    }


    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.unwrappedName
        mapItem.openInMaps()
    }
}
