//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 16.12.2024.
//
import SwiftUI
import GoogleSignIn
import Firebase

struct LoginView: View {
    @State private var userName: String = ""
    @State private var isSignedIn: Bool = false
    @State private var navigateToHome: Bool = false // Geçiş kontrolü
    
    var body: some View {
        NavigationStack {
            VStack {
                if isSignedIn {
                    // Giriş başarılıysa HomePageView göster
                    HomePageView()
                } else {
                    Spacer()
                    
                    // Google Logo
                    Image(systemName: "globe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("Google ile Giriş Yap")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Google Sign-In Button
                    Button(action: signInWithGoogle) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title)
                            Text("Google ile Devam Et")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // Signed In User Information
                    if isSignedIn {
                        Text("Hoşgeldin, \(userName)")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                    
                    // Navigation to HomePageView
                    NavigationLink(
                        destination: HomePageView(),
                        isActive: $navigateToHome
                    ) {
                        EmptyView()
                    }
                }
            }
        }
    }
    
    // MARK: - Google Sign-In Handler
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
            isSignedIn = true // Giriş durumu başarılı
            
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

