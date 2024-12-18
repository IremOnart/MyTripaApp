//
//  AddTripView.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 15.12.2024.
//

import SwiftUI

struct AddTripView: View {
    @State private var tripName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    @Binding var trips: [Trip] // Binding to pass trips back to the parent view

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

        // Add the new trip to the trips array
        let newTrip = Trip(id: trips.count + 1, name: tripName, startDate: formatDate(startDate), endDate: formatDate(endDate), image: "defaultImage")
        trips.append(newTrip)

        // Dismiss the view and return to the home page
        presentationMode.wrappedValue.dismiss()
    }
    
    // Helper function to format Date as a String
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

//struct AddTripView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTripView(trips: .constant([]))
//    }
//}
