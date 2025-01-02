//
//  TripDetailsView.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 15.12.2024.
//

import SwiftUI
import CoreData

struct TripDetailsView: View {
    @State public var trip: TripEntity
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // Header Section
            VStack(alignment: .leading) {
                Text(trip.wrappedName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("\(formatDate(trip.wrappedStartDate)) - \(formatDate(trip.wrappedEndDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()

            // TabView for Locations and Expenses
            TabView {
                // Locations Tab
                VStack {
                    Text("Konumlar")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)

                    List {
                        ForEach(trip.locationsArray, id: \.self) { location in
                            NavigationLink(destination: LocationDetailsView(location: location).environment(\.managedObjectContext, persistenceController.viewContext)) {
                                VStack(alignment: .leading) {
                                    Text(location.unwrappedName)
                                        .font(.headline)
                                    Text(location.unwrappedlocationDescription)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(formatDate(location.unwrappedDate))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteLocation)
                    }
                    
                    NavigationLink(destination: AddLocationView(trips: trip).environment(\.managedObjectContext, persistenceController.viewContext)) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.title)
                            Text("Yeni Konum Ekle")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                    }
                }
                .tabItem {
                    Label("Konumlar", systemImage: "mappin.and.ellipse")
                }

                // Expenses Tab
                VStack {
                    Text("Giderler")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)

                    List {
                        ForEach(trip.expensesArray, id: \.self) { expense in
                            VStack(alignment: .leading) {
                                Text(expense.unwrappedName)
                                    .font(.headline)
                                Text("$\(expense.unwrappedAmount, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(formatDate(expense.unwrappedDate))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteExpense)
                    }

                    NavigationLink(destination: AddExpenseView(trips: trip).environment(\.managedObjectContext, persistenceController.viewContext)) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.title)
                            Text("Yeni Gider Ekle")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                    }
                }
                .tabItem {
                    Label("Giderler", systemImage: "creditcard")
                }
            }
        }
//        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteLocation(offsets: IndexSet) {
        withAnimation {
            offsets.map { trip.locationsArray[$0] }.forEach { location in
                viewContext.delete(location)
            }
            saveContext()
        }
    }

    private func deleteExpense(offsets: IndexSet) {
        withAnimation {
            offsets.map { trip.expensesArray[$0] }.forEach { expense in
                viewContext.delete(expense)
            }
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Veriler kaydedilemedi: \(error.localizedDescription)")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
