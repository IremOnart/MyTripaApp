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
import FirebaseFirestoreInternal

@main
struct MyTripsAppApp: App {
    init() {
        // Uygulama başladığında bildirim izni iste
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Bildirim izni verildi")
            }
        }
    }
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

struct HomePageView: View {
    @State private var highlightedTripIndex: Int? = nil
    var db = Firestore.firestore()
    var service: MyTripsaAppServiceProtocol = MyTripsaAppService()
    @State var nameCount: Int = 0
    @StateObject private var locationManager = LocationManager()
    let persistenceController = PersistenceController.shared
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    @State private var isThemePickerPresented: Bool = false
    @State private var selectedTheme: Theme = ThemeManager.shared.currentTheme
    private var notificationPublisher = NotificationCenter.default.publisher(for: .travelDateArrived)
    
    @FetchRequest(sortDescriptors: []) var tripler: FetchedResults<TripEntity>
    
    
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
                    List {
                        ForEach(tripler.indices, id: \.self) { index in
                            let trip = tripler[index]
                            NavigationLink(destination: TripDetailsView(trip: trip).environment(\.managedObjectContext, persistenceController.viewContext)) {
                                TripCardView(trip: trip, isHighlighted: index == highlightedTripIndex)
                                    .onAppear {
                                        checkAndRevertColor(for: trip, at: index)
                                    }
                            }
                        }
                        .onDelete(perform: deleteTrip)
                    }

                    // Add New Trip Button
                    NavigationLink(destination: AddTripView().environment(\.managedObjectContext, persistenceController.viewContext)) {
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
            } .onReceive(notificationPublisher) { notification in
                if let userInfo = notification.userInfo,
                   let index = userInfo["index"] as? Int,
                   let isHighlighted = userInfo["highlighted"] as? Bool {
                    if isHighlighted {
                        highlightedTripIndex = index
                    } else {
                        highlightedTripIndex = nil
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isThemePickerPresented = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                    }
                    .popover(isPresented: $isThemePickerPresented) {
                        ThemePickerView(selectedTheme: $selectedTheme, isPresented: $isThemePickerPresented)
                    }
                }
            }
            
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
                    nameCount += 1
                }
            }
            UserDefaults.standard.set(nameCount, forKey: "nameCount")
        }
    }
    
    private func deleteTrip(offsets: IndexSet) {
        withAnimation {
            offsets.map { tripler[$0] }.forEach { trip in
                viewContext.delete(trip)
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
    
    private func handleTripHighlight(notification: Notification) {
        if let userInfo = notification.userInfo,
           let index = userInfo["index"] as? Int,
           let isHighlighted = userInfo["highlighted"] as? Bool {
            if isHighlighted {
                highlightedTripIndex = index
            } else {
                highlightedTripIndex = nil
            }
        }
    }
    
    private func checkAndRevertColor(for trip: TripEntity, at index: Int) {
        let startDate = trip.wrappedStartDate
        let endDate = trip.wrappedEndDate

        let today = Date()

        if today >= startDate && today <= endDate {
            // Bugün startDate ve endDate arasında ise, rengi değiştir
            if highlightedTripIndex != index {
                highlightedTripIndex = index
                NotificationCenter.default.post(name: .travelDateArrived, object: nil, userInfo: ["index": index, "highlighted": true])
            }
        } else {
            // Bugün startDate ve endDate arasında değilse, eski haline döndür
            if highlightedTripIndex == index {
                highlightedTripIndex = nil
                NotificationCenter.default.post(name: .travelDateArrived, object: nil, userInfo: ["index": index, "highlighted": false])
            }
        }
    }


}

struct TripCardView: View {
    let trip: TripEntity
    let isHighlighted: Bool
    
    var body: some View {
        HStack {
            if let imageName = trip.image,
               let image = fetchImageFromDocumentsDirectory(imageName: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                    .clipped()
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(trip.wrappedName)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(formatDate(trip.wrappedStartDate)) - \(formatDate(trip.wrappedEndDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(isHighlighted ? Color.yellow : Color.white) // Change the color when highlighted
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
//        .onAppear {
//            // Check and revert color when needed
//            checkAndRevertColor(for: trip)
//        }
    }
    
    private func fetchImageFromDocumentsDirectory(imageName: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(imageName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            print("Hata: Görsel bulunamadı - \(imageName)")
            return nil
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
//    private func checkAndRevertColor(for trip: TripEntity) {
//        if let endDate = trip.wrappedEndDate as? Date {
//            if Date() >= endDate {
//                if highlightedTripIndex == index {
//                    highlightedTripIndex = nil
//                }
//            }
//        } else {
//            print("Error: Invalid end date for trip: \(trip.wrappedName)")
//        }
//    }
}


// Trip Model
struct Trip: Identifiable {
    let id: UUID
    let name: String
    let startDate: String
    let endDate: String
    let image: String
}


extension Notification.Name {
    static let travelDateArrived = Notification.Name("travelDateArrived")
}
