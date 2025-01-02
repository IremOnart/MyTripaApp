//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 2.01.2025.
//

import SwiftUICore
import SwiftUI

struct ThemePickerView: View {
    @Binding var selectedTheme: Theme
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Tema Seçimi")
                .font(.headline)
                .padding()

            Picker("Tema", selection: $selectedTheme) {
                Text("Açık").tag(Theme.light)
                Text("Koyu").tag(Theme.dark)
                Text("Sistem Varsayılanı").tag(Theme.system)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedTheme) { newTheme in
                ThemeManager.shared.currentTheme = newTheme
                isPresented = false // Popover'ı kapat
            }

            Button("Kapat") {
                isPresented = false
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

