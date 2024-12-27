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
    
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Konum güncelleme bilgisi alındığında çalışır
        guard let location = locations.last else { return }
        
        // Eğer konum güncellenmişse, ana iş parçacığında değeri güncelle
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            print("Enlem: \(self.latitude), Boylam: \(self.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alma hatası: \(error.localizedDescription)")
    }
}
