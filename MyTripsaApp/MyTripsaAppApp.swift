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

@main
struct MyTripsAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            LoginView() // Launch the Home Page as the main screen
        }
    }
}

struct HomePageView: View {
    // Sample Trips Data
    @State private var trips: [Trip] = [
        Trip(id: 1, name: "İtalya Gezisi", startDate: "15 Aralık 2024", endDate: "20 Aralık 2024", image: "italy"),
        Trip(id: 2, name: "Paris Turu", startDate: "1 Ocak 2025", endDate: "5 Ocak 2025", image: "paris")
    ]
    @State private var userName: String = ""
    
    var body: some View {
        Button(action: {
            signInWithGoogle()
        }) {
            HStack {
                Image(systemName: "logo.google")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Google ile Giriş Yap")
                    .padding()
            }
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        
        NavigationView {
            VStack {
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
                NavigationLink(destination: AddTripView(trips: $trips)) {
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
            .navigationBarHidden(true)
        }
    }
    
    func signInWithGoogle() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { [self] result, error in
            guard error == nil else {
                print("Error signing in: \(error?.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                print("Error signing in: \(error?.localizedDescription)")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            // ...
        }
        
    }
    
    // Root view controller'ı almak için kullanılan fonksiyon
    func getRootViewController() -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            fatalError("Could not get root view controller")
        }
        return rootViewController
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
    let id: Int
    let name: String
    let startDate: String
    let endDate: String
    let image: String
}

//// Trip Details View (Example)
//struct TripDetailsView: View {
//    let trip: Trip
//
//    var body: some View {
//        VStack {
//            Text("Seyahat Detayları")
//                .font(.largeTitle)
//            Text(trip.name)
//                .font(.title2)
//                .padding(.top)
//            Spacer()
//        }
//        .navigationTitle(trip.name)
//    }
//}

// Preview
//struct HomePageView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomePageView()
//    }
//}
