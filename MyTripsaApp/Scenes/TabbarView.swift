//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 25.12.2024.
//
import SwiftUICore
import SwiftUI

struct TabbarView: View {
    @State var selection: Int = 0
    let persistenceController = PersistenceController.shared
    var  body: some View {
        TabView {
            HomePageView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home Page")
                }.tag(0)
            
            AttractionPointsView()
                .tabItem {
                    Image(systemName: "mappin.circle.fill")
                    Text("Attraction Points")
                }
        }
    }
}
