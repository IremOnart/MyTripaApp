//
//  Untitled.swift
//  AddLocationView
//
//  Created by İrem Onart on 25.12.2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct AddLocationView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default location (San Francisco)
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedDate: Date = Date() // Date picked by user
    let persistenceController = PersistenceController.shared
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @StateObject var trips: TripEntity // Change to TripEntity, as it's Core Data entity

    var body: some View {
        ScrollView {  // ScrollView to handle larger content
            VStack {
                // Location Name and Description
                TextField("Location Name", text: $name)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Description", text: $description)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Date Picker
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .padding()
                    .datePickerStyle(WheelDatePickerStyle())

                // Map View
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $userTrackingMode)
                    .frame(height: 300)
                    .onTapGesture {
                        let tappedLocation = region.center // Get tapped location from region
                        region.center = tappedLocation // Update the center of the region
                        selectedLocation = tappedLocation // Update selected location
                    }
                    .padding()
                
                if let selectedLocation = selectedLocation {
                    Text("Selected Location: \(selectedLocation.latitude), \(selectedLocation.longitude)")
                        .padding()
                }

                Button("Save Location") {
                    saveLocation()
                }
                .padding()
            }
            .navigationBarTitle("Add Location")
        }
    }

    // Save location to Core Data
    func saveLocation() {
        guard let selectedLocation = selectedLocation else {
            print("Location not selected!")
            return
        }

        let newLocation = LocationEntity(context: viewContext)
        newLocation.name = name
        newLocation.locationDescription = description
        newLocation.latitude = selectedLocation.latitude
        newLocation.longitude = selectedLocation.longitude
        newLocation.date = selectedDate // Save the selected date
        newLocation.trip = trips // Associate this location with the selected trip

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // Dismiss view after saving
            print("Location saved successfully.")
        } catch {
            print("Failed to save location: \(error.localizedDescription)")
        }
    }
}


