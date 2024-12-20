//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 19.12.2024.
//

import Foundation

class BaseENV {
    let dict: NSDictionary
    
    init(resourceName: String) {
        guard let filePath = Bundle.main.path(forResource: resourceName, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else {
            fatalError("couldnt find file \(resourceName) plist")
        }
        self.dict = plist
    }
}

protocol APIKeyable {
    var Feature_API: String { get }
}

class ProdENV: BaseENV, APIKeyable {
    init() {
        super.init(resourceName: "PropertyList")
    }
    
    var Feature_API: String {
        dict.object(forKey: "Features_APIKEY") as? String ?? ""
    }
    
}
