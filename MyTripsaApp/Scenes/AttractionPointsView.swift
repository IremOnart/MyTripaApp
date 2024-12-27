//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 25.12.2024.
//

import SwiftUICore
import SwiftUI
import MapKit

struct AttractionPointsView: View {
    @State private var places: [Place] = []
    @State private var nameCount: Int = 0
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.137787, longitude: 11.575343),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Turistik Yerler")
                    .font(.title)
                    .padding()
                
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: places) { place in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: place.coordinates[1], longitude: place.coordinates[0])) {
                        VStack {
                            Button(action: {
                                openInAppleMaps(place: place)
                            }) {
                                Image(systemName: "star.fill") // Örnek bir sistem simgesi
                                    .foregroundColor(.red)
                                    .font(.title)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Text(place.names) // Display place names as annotation
                                .font(.caption)
                                .foregroundColor(.black)
                            
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    Database.shared.getFeaturesDatabase { place, error in
                        if let error = error {
                            print(error)
                        } else {
                            guard let place = place else {
                                return
                            }
                            self.places = place
                            print(self.places)
                        }
                    }
                }
            }
            .navigationBarTitle("Harita", displayMode: .inline)
        }
    }
    
    func openInAppleMaps(place: Place) {
        let coordinate = CLLocationCoordinate2D(latitude: place.coordinates[1], longitude: place.coordinates[0])
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        // Open location in Apple Maps
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    func loadPlaces() {
        // Geoapify firebase data al
        
    }
}

