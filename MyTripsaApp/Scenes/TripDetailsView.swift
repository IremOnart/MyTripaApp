//
//  TripDetailsView.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 15.12.2024.
//

import SwiftUI

struct TripDetailsView: View {
    let trip: Trip
    
    // Sample Data for Locations and Expenses
    @State private var locations: [Location] = [
        Location(id: 1, name: "Colosseum", description: "Roma'nın tarihi amfitiyatrosu.", date: "16 Aralık 2024"),
        Location(id: 2, name: "Vatikan Müzesi", description: "Sanat ve tarih dolu.", date: "17 Aralık 2024")
    ]
    
    @State private var expenses: [Expense] = [
        Expense(id: 1, name: "Uçak Bileti", amount: 250.0, date: "10 Aralık 2024"),
        Expense(id: 2, name: "Otel Konaklama", amount: 500.0, date: "16 Aralık 2024")
    ]
    
    var body: some View {
        VStack {
            // Header Section
            VStack(alignment: .leading) {
                Text(trip.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("\(trip.startDate) - \(trip.endDate)")
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
                        ForEach(locations) { location in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(location.name)
                                        .font(.headline)
                                    Text(location.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(location.date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .onDelete(perform: deleteLocation)
                    }
                    
                    Button(action: {
                        print("Yeni konum ekleye tıklandı")
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Yeni Konum Ekle")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
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
                        ForEach(expenses) { expense in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(expense.name)
                                        .font(.headline)
                                    Text("$\(expense.amount, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(expense.date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .onDelete(perform: deleteExpense)
                    }
                    
                    Button(action: {
                        print("Yeni gider ekleye tıklandı")
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Yeni Gider Ekle")
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
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    print("Seyahat düzenleme butonuna tıklandı")
                }) {
                    Image(systemName: "pencil")
                }
            }
        }
    }
    
    // Delete Handlers
    private func deleteLocation(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
    }
    
    private func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
    }
}

// Models
struct Location: Identifiable {
    let id: Int
    let name: String
    let description: String
    let date: String
}

struct Expense: Identifiable {
    let id: Int
    let name: String
    let amount: Double
    let date: String
}
