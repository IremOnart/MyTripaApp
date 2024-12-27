//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 19.12.2024.
//

public struct FeatureCollection: Decodable {
    public let features: [Feature]
}

public struct Feature: Decodable {
    public let properties: Properties
    public let geometry: Geometry
}

public struct Properties: Decodable {
    public let name: String?
    public let country: String?
    public let city: String?
    public let formatted: String?
    
}

public struct Geometry: Decodable {
    public let coordinates: [Double]
}


