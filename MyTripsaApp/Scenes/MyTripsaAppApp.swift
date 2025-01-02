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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            LoginView()
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
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    @State private var isThemePickerPresented: Bool = false
    @State private var selectedTheme: Theme = ThemeManager.shared.currentTheme
    
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
                        ForEach(tripler, id: \.self) { trip in
                            NavigationLink(destination: TripDetailsView(trip: trip).environment(\.managedObjectContext, persistenceController.viewContext)) {
                                TripCardView(trip: trip)
                            }
                        }
                        .onDelete(perform: deleteTrip)
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
                    nameCount+=1
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
}

// Trip Card View
struct TripCardView: View {
    let trip: TripEntity
    
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
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
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
    
    func dataToBase64String(data: Data) -> String {
        return data.base64EncodedString()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
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
