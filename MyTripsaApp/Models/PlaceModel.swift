//
//  PlaceModel.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 10.01.2025.
//

import Foundation

struct ApiResponse: Codable {
    public let results: [PlaceModel]
}

struct PlaceModel: Identifiable, Codable, Equatable {
    public let id: String?
    public let name: String?
    public let location: Location?
    public let coordinates: Coordinates
    
    enum CodingKeys: String, CodingKey {
        case id = "fsq_id"
        case name
        case location
        case coordinates = "geocodes"
    }
    
    static func == (lhs: PlaceModel, rhs: PlaceModel) -> Bool {
            return lhs.id == rhs.id
        }
}

struct Location: Codable {
    public let address: String?
    public let locality: String? // Şehir ismi
    
    enum CodingKeys: String, CodingKey {
        case address
        case locality
    }
}

struct Main: Codable {
    let latitude: Double
    let longitude: Double
}

struct Coordinates: Codable {
    public let main: Main
}
