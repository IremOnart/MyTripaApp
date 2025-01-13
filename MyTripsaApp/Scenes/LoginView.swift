//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 16.12.2024.
//
import SwiftUI
import GoogleSignIn
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignedIn: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSignUp: Bool = false // Sign-Up sayfasına geçiş kontrolü
    @State private var userName: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                if isSignedIn {
                    TabbarView()
                } else {
                    Spacer()

//                    // Animasyonlu başlık
//                    Text("MyTripsaApp")
//                        .font(.system(size: 40, weight: .bold))
//                        .foregroundColor(.blue)

                    Image("loginImage-Photoroom")
                        .resizable()
                        .scaledToFit()
//                        .frame(width: 200, height: 200)
                        .foregroundColor(.blue)
                        .padding(.top, 20)

                    Spacer()

                    loginForm.padding()

                    Spacer()

                    // Google ile giriş butonu
                    Button(action: signInWithGoogle) {
                        HStack(spacing: 10) { // Görsel aralığı artırmak için spacing ekledim
                            Image("google")
                                .resizable()
                                .frame(width: 24, height: 24) // Google ikonunun boyutunu ayarladım
                                .clipShape(Circle()) // İsteğe bağlı: İkonu yuvarlak hale getirebilir
                                .padding(.leading, 10)
                            
                            Text("Google ile Giriş Yap")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                        }
                        .padding()
                        .frame(maxWidth: 250, minHeight: 50)
                        .background(Color.white)
                        .cornerRadius(40)
                    }

                    // Sign-Up sayfasına geçiş butonu
                    Button(action: {
                        showSignUp = true
                    }) {
                        Text("Hesabın yok mu? Kayıt Ol")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .padding(20)
                    
                    NavigationLink(destination: SignUpView(), isActive: $showSignUp) {
                        EmptyView()
                    }

                    NavigationLink(destination: TabbarView(), isActive: $navigateToHome) {
                        EmptyView()
                    }
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#1DAEDE"), Color(hex: "#FFC83D")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }

    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 16) {
            TextField("E-posta", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Şifre", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button(action: emailSignIn) {
                Text("Giriş Yap")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
        .shadow(radius: 10)
    }

    // MARK: - Email Sign-In Handler
    func emailSignIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                showError = true
                errorMessage = "Giriş başarısız: \(error.localizedDescription)"
                return
            }
            // Giriş başarılı
            isSignedIn = true
            navigateToHome = true
        }
    }

    // MARK: - Google Sign-In Handler
        func signInWithGoogle() {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { [self] result, error in
                guard error == nil else {
                    print("Error signing in: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    print("Error: Missing user or idToken")
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase sign-in error: \(error.localizedDescription)")
                        return
                    }
                    isSignedIn = true
                    userName = authResult?.user.displayName ?? "Kullanıcı"
                    navigateToHome = true
                }
            }
        }
    // Helper to get root view controller
    func getRootViewController() -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
}

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToSignIn: Bool = false

    var body: some View {
        VStack {
//            Spacer()

//            Text("Kayıt Ol")
//                .font(.system(size: 40, weight: .bold))
//                .foregroundColor(.blue)

            Image("undraw_verified")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 330, maxHeight: 330)
                .foregroundColor(.blue)
                .padding(.top, 20)

            Spacer()

            signUpForm

            Spacer()

            NavigationLink(destination: LoginView(), isActive: $navigateToSignIn) {
                EmptyView()
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#1DAEDE"), Color(hex: "#FFC83D")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
        )
    }

    // MARK: - Sign-Up Form
    private var signUpForm: some View {
        VStack(spacing: 16) {
            TextField("E-posta", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Şifre", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button(action: signUp) {
                Text("Kayıt Ol")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
        .shadow(radius: 10)
    }

    // MARK: - Sign-Up Handler
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                showError = true
                errorMessage = "Kayıt başarısız: \(error.localizedDescription)"
                return
            }
            // Kayıt başarılı, giriş sayfasına yönlendir
            navigateToSignIn = true
        }
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        let scanner = Scanner(string: hexSanitized)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
