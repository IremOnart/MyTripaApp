//
//  TripEntity+CoreDataProperties.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 30.12.2024.
//
//

import Foundation
import CoreData


extension TripEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TripEntity> {
        return NSFetchRequest<TripEntity>(entityName: "TripEntity")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var image: String?
    @NSManaged public var locations: NSSet?
    @NSManaged public var expenses: NSSet?
    
    
    public var wrappedName: String {
        name ?? "Unkown name"
    }
    public var wrappedStartDate: Date {
        startDate ?? Date()
    }
    public var wrappedEndDate: Date {
        endDate ?? Date()
    }
    public var wrappedImage: String {
        image ?? "Unkown image"
    }
    
    public var locationsArray: [LocationEntity] {
        let locationSet = locations as? Set<LocationEntity> ?? []
        
        return locationSet.sorted {
            $0.unwrappedName < $1.unwrappedName
        }
    }
    
    public var expensesArray: [ExpensesEntity] {
        let expensesSet = expenses as? Set<ExpensesEntity> ?? []
        
        return expensesSet.sorted {
            $0.unwrappedName < $1.unwrappedName
        }
    }

}

// MARK: Generated accessors for locations
extension TripEntity {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: LocationEntity)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: LocationEntity)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

// MARK: Generated accessors for expenses
extension TripEntity {

    @objc(addExpensesObject:)
    @NSManaged public func addToExpenses(_ value: ExpensesEntity)

    @objc(removeExpensesObject:)
    @NSManaged public func removeFromExpenses(_ value: ExpensesEntity)

    @objc(addExpenses:)
    @NSManaged public func addToExpenses(_ values: NSSet)

    @objc(removeExpenses:)
    @NSManaged public func removeFromExpenses(_ values: NSSet)

}

extension TripEntity : Identifiable {

}
