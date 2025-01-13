//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 25.12.2024.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    // Published properties for user location and coordinates
    @Published var userLocation: CLLocationCoordinate2D?
    
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var location: CLLocation? {
            didSet {
                objectWillChange.send()
            }
        }
    
    override init() {
        super.init()
        
        // Location manager setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // CLLocationManagerDelegate method for handling location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get the latest location
        guard let location = locations.last else { return }
        
        // Update the published coordinates on the main thread
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.userLocation = location.coordinate  // Update userLocation
            print("Enlem: \(self.latitude), Boylam: \(self.longitude)")
        }
        self.location = locations.last
    }
    
    // Handle errors when location fails to update
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alma hatası: \(error.localizedDescription)")
    }
}

