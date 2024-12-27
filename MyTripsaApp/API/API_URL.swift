//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 19.12.2024.
//

import Foundation

class GeoapifyAPI {
    private var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "PropertyList", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["GeoapifyAPIKey"] as? String else {
            fatalError("API anahtarı bulunamadı!")
        }
        return key
    }

    private let baseURL = "https://api.geoapify.com/v2/places"

    func createAttractionURL(topLeftLat: Double, topLeftLon: Double, bottomRightLat: Double, bottomRightLon: Double, limit: Int) -> String {
        // URLComponents ile URL'yi oluştur
        guard var urlComponents = URLComponents(string: baseURL) else {
            fatalError("Geçersiz base URL!")
        }

        // Query parametrelerini ekle
        urlComponents.queryItems = [
            URLQueryItem(name: "categories", value: "tourism.attraction"),
            URLQueryItem(name: "filter", value: "rect:\(topLeftLon),\(topLeftLat),\(bottomRightLon),\(bottomRightLat)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]

        // URL'yi String olarak döndür
        guard let urlString = urlComponents.url?.absoluteString else {
            fatalError("URL oluşturulamadı!")
        }

        return urlString
    }
}

//class BaseENV {
//    let dict: NSDictionary
//    
//    init(resourceName: String) {
//        guard let filePath = Bundle.main.path(forResource: resourceName, ofType: "plist"),
//              let plist = NSDictionary(contentsOfFile: filePath) else {
//            fatalError("couldnt find file \(resourceName) plist")
//        }
//        self.dict = plist
//    }
//}
//
//protocol APIKeyable {
//    var Feature_API: String { get }
//}
//
//class ProdENV: BaseENV, APIKeyable {
//    init() {
//        super.init(resourceName: "PropertyList")
//    }
//    
//    var Feature_API: String {
//        dict.object(forKey: "Features_APIKEY") as? String ?? ""
//    }
//    
//}
