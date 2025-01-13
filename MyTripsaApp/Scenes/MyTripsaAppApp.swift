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
            SplashView()
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
    @State private var isSignOutAlertPresented = false
    
    private var userId: String? {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            return nil
        }
        return user.userID
    }
    
    // FetchRequest'i kullanıcı ID'sine göre filtrele
    @FetchRequest private var tripler: FetchedResults<TripEntity>
    
    init() {
        // Set up the navigation bar appearance
        let appearance = UINavigationBarAppearance()
//        appearance.backgroundColor = UIColor(hex: "#FFC83D")// Set the background color
//        UINavigationBar.appearance().titleTextAttributes = [
//            .foregroundColor: UIColor(hex: "#FFC83D", alpha: 1.0) // Ensure full opacity
//        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        // Eğer kullanıcı girişi varsa, o kullanıcının seyahatlerini getir
        let predicate: NSPredicate?
        if let userId = GIDSignIn.sharedInstance.currentUser?.userID {
            predicate = NSPredicate(format: "userID == %@", userId)
        } else {
            predicate = nil
        }
        
        // FetchRequest'i oluştur
        _tripler = FetchRequest(
            entity: TripEntity.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \TripEntity.startDate, ascending: true)
            ],
            predicate: predicate
        )
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Veriler yükleniyor...")
                        .padding()
                } else {
                    // Title
//                    Text("Seyahatlerim")
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .padding(.top)
                    
                    // Trips List
                    List {
                        ForEach(tripler.indices, id: \.self) { index in
                            let trip = tripler[index]
                            NavigationLink(destination: TripDetailsView(trip: trip).environment(\.managedObjectContext, persistenceController.viewContext)) {
                                TripCardView(trip: trip, isHighlighted: index == highlightedTripIndex)
                                    .onAppear {
                                        checkAndRevertColor(for: trip, at: index)
                                    }
                            }.listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteTrip)
                    }.listStyle(PlainListStyle())
                    
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
                        .background(Color(hex: "#1DAEDE"))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding()
                        .padding(.bottom, 32)
                    }
                }
            }.navigationTitle("Seyahatlerim")
                .onReceive(notificationPublisher) { notification in
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
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            isSignOutAlertPresented = true
                        }) {
                            Image(systemName: "power")
                                .font(.title2)
                                .foregroundColor(.red) // Çıkış butonunu vurgulamak için
                                .padding()
                        }
                        .alert(isPresented: $isSignOutAlertPresented) {
                            Alert(
                                title: Text("Çıkış Yap"),
                                message: Text("Emin misiniz?"),
                                primaryButton: .destructive(Text("Çıkış Yap")) {
                                    signOutFromGoogle()
                                },
                                secondaryButton: .cancel(Text("İptal"))
                            )
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isThemePickerPresented = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .padding()
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
    
    func signOutFromGoogle() {
        GIDSignIn.sharedInstance.signOut()
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                print("Error disconnecting: \(error)")
            } else {
                print("Successfully disconnected.")
                navigateToLoginView()
            }
        }
    }
    
    // LoginView'e geçiş için navigation fonksiyonu
    func navigateToLoginView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let loginView = LoginView() // LoginView'inizi buraya tanımlayın
            window.rootViewController = UIHostingController(rootView: loginView)
            window.makeKeyAndVisible()
        }
    }
    
    func getUserID() -> String? {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("No user signed in")
            return nil
        }
        return user.userID
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
        //        .padding()
        .background(isHighlighted ? Color.yellow : Color.white) // Change the color when highlighted
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


extension Notification.Name {
    static let travelDateArrived = Notification.Name("travelDateArrived")
}

// UIColor extension to handle hex color
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}


