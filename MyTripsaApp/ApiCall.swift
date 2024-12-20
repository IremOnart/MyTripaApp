//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 19.12.2024.
//

import Foundation
import UIKit

public protocol MyTripsaAppServiceProtocol {
    func fetchFeatures(url: String, completion: @escaping (FeatureCollection) -> Void)
}

public class MyTripsaAppService: MyTripsaAppServiceProtocol {
    
    public init() {}
    
    public func fetchFeatures(url: String, completion: @escaping (FeatureCollection) -> Void) {
        let url = URL(string: url)!
        URLSession.shared.dataTask(with: url) { (data, _ , error) in
            if let error = error {
                print(error.localizedDescription)
            }else if let data = data{
                let coins = try? JSONDecoder().decode(FeatureCollection.self, from: data)
                print(coins as Any)
                if let coins = coins{
                completion(coins)
                }
            }
        }.resume()
    }
    
}
