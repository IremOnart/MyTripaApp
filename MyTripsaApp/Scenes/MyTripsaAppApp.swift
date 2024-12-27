//
//  MyTripsaAppApp.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 15.12.2024.
//
import SwiftUI
import GoogleSignIn
import FirebaseCore
import Firebase
import FirebaseAuth
import CoreData

@main
struct MyTripsAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            LoginView() // Launch the Home Page as the main screen
            //            ContentView()
            //                            .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}

struct HomePageView: View {
    // Sample Trips Data
    @State private var trips: [Trip] = [
        Trip(id: UUID(), name: "İtalya Gezisi", startDate: "15 Aralık 2024", endDate: "20 Aralık 2024", image: "italy"),
        Trip(id: UUID(), name: "Paris Turu", startDate: "1 Ocak 2025", endDate: "5 Ocak 2025", image: "paris")
    ]
    @State private var userName: String = ""
    var db = Firestore.firestore()
    var service: MyTripsaAppServiceProtocol = MyTripsaAppService()
    @State var nameCount: Int = 0
    @StateObject private var locationManager = LocationManager()
    let persistenceController = PersistenceController.shared
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Veriler yükleniyor...")
                        .padding()
                } else {
                    // Title
                    Text("Seyahatlerim")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Trips List
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(trips) { trip in
                                NavigationLink(destination: TripDetailsView(trip: trip)) {
                                    TripCardView(trip: trip)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Add New Trip Button
                    NavigationLink(destination: AddTripView(trips: $trips).environment(\.managedObjectContext, persistenceController.viewContext)) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.title)
                            Text("Yeni Seyahat Ekle")
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
            }.onAppear{
                fetchTrips()
            }
            .navigationBarHidden(true)
        }.onAppear {
            let api = GeoapifyAPI()
            let urlString = api.createAttractionURL(
                topLeftLat: 48.13898913611139,
                topLeftLon: 11.573106549898483,
                bottomRightLat: 48.13666585409989,
                bottomRightLon: 11.57704581350751,
                limit: 20
            )
            print(urlString)
            service.fetchFeatures(url: urlString) { [self] result in
                //                guard let self = self else { return }  // self'in nil olmadığından emin olun
                for name in result.features {
                    Database.shared.setFeaturesDatabase(name: name, documentName: "\(nameCount)" ){ error in
                        if let error = error {
                            print(error)
                        } else {
                            print("success")
                        }
                    }
                    nameCount+=1
                }
            }
            UserDefaults.standard.set(nameCount, forKey: "nameCount")
        }
    }
    
    private func fetchTrips() {
        isLoading = true
        let request: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        
        // Verilerin sıralanması
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TripEntity.startDate, ascending: true)]
        
        do {
            let tripEntities = try viewContext.fetch(request)
            
            // Core Data verilerini Trip struct'ına dönüştürme
            trips = tripEntities.map { tripEntity in
                Trip(
                    id: tripEntity.id ?? UUID(), // Core Data'daki id'yi kullan
                    name: tripEntity.name ?? "Bilinmiyor", // Name'yi al
                    startDate: formatDate(tripEntity.startDate ?? Date()), // Tarih formatlama
                    endDate: formatDate(tripEntity.endDate ?? Date()), // Tarih formatlama
                    image: "defaultImage" // Görsel bilgisi
                )
            }
        } catch {
            print("Veriler çekilemedi: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
}

// Trip Card View
struct TripCardView: View {
    let trip: Trip
    
    var body: some View {
        HStack {
            Image(trip.image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(trip.startDate) - \(trip.endDate)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// Trip Model
struct Trip: Identifiable {
    let id: UUID
    let name: String
    let startDate: String
    let endDate: String
    let image: String
}


// Preview
//struct HomePageView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomePageView()
//    }
//}
