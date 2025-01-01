//
//  LocationEntity+CoreDataProperties.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 30.12.2024.
//
//

import Foundation
import CoreData


extension LocationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationEntity> {
        return NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var locationDescription: String?
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var trip: TripEntity?
    
    public var unwrappedName: String {
        return name ?? "Unknown Name"
    }
    
    public var unwrappedDate: Date {
        return date ?? Date()
    }
    
    public var unwrappedlatitude: Double {
        return latitude
    }
    
    public var unwrappedlocationDescription: String {
        return locationDescription ?? "Unknown Name"
    }
    
    public var unwrappedlongitude: Double {
        return longitude
    }
 
}

extension LocationEntity : Identifiable {

}
