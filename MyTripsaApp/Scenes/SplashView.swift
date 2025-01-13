//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 13.01.2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 1
    
    var body: some View {
        if isActive {
            // Ana uygulama ekranına geçiş
            LoginView()
        } else {
            ZStack {
                Image("myLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scaleEffect)
                    .frame(width: 80)
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeOut(duration: 1)) {
                    scaleEffect = 0.6
                }
                
                withAnimation(.easeOut(duration: 1).delay(1)) {
                    scaleEffect = 2
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isActive = true
                }
            }
        }
    }
}
