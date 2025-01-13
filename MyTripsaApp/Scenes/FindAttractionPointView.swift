//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 10.01.2025.
//

import SwiftUI
import Combine
import Foundation
import MapKit
import CoreLocation

class FoursquareViewModel: ObservableObject {
    @Published var places: [PlaceModel] = []
    
    private let apiKey = "fsq3mujvOKwaXMtCqqenwUJfyjDIijgHnUmgsB3cV8VV+ag="
    private let baseURL = "https://api.foursquare.com/v3/places/search"
    
    func fetchPlaces(city: String) async {
        let url = URL(string: "https://api.foursquare.com/v3/places/search?near=\(city)&limit=50")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "fsq3UfnskhNCL0eJXz50/J1J4piNZeEl8CcIAzfpgmulMY4="
        ]
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
            places = decodedResponse.results
            for place in decodedResponse.results {
                print("Place Name: \(place.name)")
                if let address = place.location?.address, let city = place.location?.locality {
                    print("Address: \(address), City: \(city)")
                }
            }
        } catch {
            print("Error fetching places: \(error)")
        }
    }
    
}

struct FindAttractionPointView: View {
    @StateObject private var viewModel = FoursquareViewModel()
    @State private var city = ""
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    
    @State private var region: MKCoordinateRegion
    @State private var locationManager = LocationManager()
    @State private var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State private var selectedPlace: PlaceModel?
    @State private var showButton = false
    
    init() {
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.3784, longitude: 2.1915), // Default to Barcelona
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Enter a City", text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: city) { newValue in
                        withAnimation(.easeInOut) {
                            showButton = !newValue.isEmpty // Şehir yazıldığında butonu göster, yazılmadığında gizle
                        }
                        
                        if newValue.isEmpty {
                            // Kullanıcı şehir girmediyse harita merkezini kullanıcı konumuna güncelle
                            if let userLocation = locationManager.location?.coordinate {
                                region.center = userLocation
                            }
                        }
                    }
                }.padding()
                
                // Buton animasyonlu olarak görünür
                if showButton {
                    Button(action: {
                        Task {
                            await viewModel.fetchPlaces(city: city)
                            geocodeCity(city)
                        }
                    }) {
                        Label("Search Place", systemImage: "location.magnifyingglass")
                            .padding(8)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .transition(.move(edge: .bottom)) // Buton animasyonlu olarak alttan gelsin
                }
                
                
                Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: viewModel.places) { place in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: place.coordinates.main.latitude,
                        longitude: place.coordinates.main.longitude)) {
                            VStack(spacing: 5) { // Pin ve baloncuk arasındaki boşluğu belirleyin
                                Image(systemName: "mappin")
                                    .resizable()
                                    .frame(width: 10, height: 35) // Sabit boyut
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        selectedPlace = place
                                    }
                                
                                // Baloncuk görünümü
                                if selectedPlace?.id == place.id {
                                    VStack {
                                        Text(place.name ?? "Unknown")
                                            .font(.headline)
                                        if let address = place.location?.address {
                                            Text(address)
                                                .font(.subheadline)
                                        }
                                    }.onTapGesture {
                                        openInAppleMaps(place: place)
                                    }
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 5)
                                    .frame(maxWidth: 200) // Baloncuğun genişliğini sınırlayın
                                    .lineLimit(2) // En fazla 2 satır gösterir, metin kısa ise tek satırda kalır
                                    .multilineTextAlignment(.leading) // Çok satırlı olduğunda hizalama
                                    .truncationMode(.tail) // Metin sığmazsa sonunu üç nokta ile keser
                                }
                            }
                            .animation(.easeInOut, value: selectedPlace) // Animasyon ekleyin (isteğe bağlı)
                        }
                }
                
                Spacer()
                
                //                List(viewModel.places) { place in
                //                    VStack(alignment: .leading) {
                //                        Text(place.name ?? "")
                //                            .font(.headline)
                //                        if let address = place.location?.address, let locality = place.location?.locality {
                //                            Text("\(address), \(locality)")
                //                                .font(.subheadline)
                //                                .foregroundColor(.gray)
                //                        } else {
                //                            Text("Address not available")
                //                                .font(.subheadline)
                //                                .foregroundColor(.gray)
                //                        }
                //                    }
                //                    .padding(.vertical, 5)
                //                }
            }
            .navigationTitle("Tourist Places")
        }
    }
    
    func openInAppleMaps(place: PlaceModel) {
        let coordinate = CLLocationCoordinate2D(latitude: place.coordinates.main.latitude, longitude: place.coordinates.main.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        // Open location in Apple Maps
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    private func geocodeCity(_ city: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { (placemarks, error) in
            if let error = error {
                print("Error geocoding city: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("Could not find coordinates for the city.")
                return
            }
            
            // Update region with the city's coordinates
            region.center = location.coordinate
        }
    }
}

