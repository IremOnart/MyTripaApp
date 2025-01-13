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

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                HomePageView().environment(\.managedObjectContext, persistenceController.viewContext)
                    .tag(0)
                
                FindAttractionPointView()
                    .tag(1)
            }
            .overlay(
                ZStack {
                    HStack {
                        ForEach(TabbedItems.allCases, id: \.self) { item in
                            Button {
                                selection = item.rawValue
                            } label: {
                                CustomTabItem(imageName: item.iconName, title: item.title, isActive: selection == item.rawValue)
                            }
                        }
                    }
                    .padding(6)
                    .frame(height: 70)
                    .background(Color(hex: "#1DAEDE").opacity(0.6))
                    .cornerRadius(35)
                    .padding(.horizontal, 26)
                }
                , alignment: .bottom
            )
        }
    }
}

extension TabbarView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(systemName: imageName) // Make sure it's a system icon
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .black : .gray)
                .frame(width: 20, height: 20)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .black : .gray)
            }
            Spacer()
        }
        .frame(width: isActive ? .infinity : 150, height: 60)
        .background(isActive ? Color(hex: "#1DAEDE").opacity(0.8) : Color.clear)
        .cornerRadius(30)
    }
}

enum TabbedItems: Int, CaseIterable {
    case home = 0
    case attractionPoint
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .attractionPoint:
            return "Attraction Points"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "house.fill"
        case .attractionPoint:
            return "mappin.circle.fill"
        }
    }
}
