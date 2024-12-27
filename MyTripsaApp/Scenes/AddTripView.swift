//
//  AddTripView.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 15.12.2024.
//

import SwiftUI
import CoreData

struct AddTripView: View {
    @State private var tripName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @Binding var trips: [Trip] // Binding to pass trips back to the parent view
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext // Core Data Context
    
    var body: some View {
        NavigationView {
            VStack {
                // Title
                Text("Yeni Seyahat Ekle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Form to input trip details
                Form {
                    Section(header: Text("Seyahat Bilgileri")) {
                        TextField("Seyahat Adı", text: $tripName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        DatePicker("Başlangıç Tarihi", selection: $startDate, displayedComponents: .date)
                            .padding()
                        
                        DatePicker("Bitiş Tarihi", selection: $endDate, displayedComponents: .date)
                            .padding()
                    }
                    
                    // Save button
                    Button(action: {
                        saveTrip()
                    }) {
                        Text("Kaydet")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                }
                .navigationBarItems(leading: Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
    
    // Function to save the new trip
    private func saveTrip() {
        // Validate input
        if tripName.isEmpty {
            // Handle empty trip name (e.g., show an alert)
            return
        }

        // Create a new Trip entity
        let newTrip = TripEntity(context: managedObjectContext)
        newTrip.id = UUID()
        newTrip.name = tripName
        newTrip.startDate = startDate
        newTrip.endDate = endDate
        print("ID: \(UUID())")
        print("Name: \(tripName)")
        print("Start Date: \(startDate)")
        print("End Date: \(endDate)")

        // Save to Core Data
        do {
            try managedObjectContext.save()
            presentationMode.wrappedValue.dismiss()
            print("başarılı kaydetme")
        } catch {
            // Handle Core Data saving error
            print("Failed to save trip: \(error.localizedDescription)")
        }
    }
}
