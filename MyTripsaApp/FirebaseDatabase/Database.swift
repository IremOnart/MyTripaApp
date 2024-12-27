//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 25.12.2024.
//

import FirebaseFirestoreInternal
import FirebaseCore
import Firebase
import FirebaseAuth

class Database {
    static var shared = Database()
    private init(){}
    
    var db = Firestore.firestore()
    
    func setFeaturesDatabase(name: Feature, documentName: String, completion: @escaping(Error?) -> Void) {
        db.collection("attractionPoints").document(documentName).setData(["names": name.properties.name ?? "", "country": name.properties.country, "city": name.properties.city, "formatted": name.properties.formatted, "coordinates": name.geometry.coordinates]) { error in
            if error == nil {
                completion(nil)
            } else {
                completion(error)
            }
            
        }
    }
    
    func getFeaturesDatabase(complition: @escaping([Place]?,Error?) -> Void) {
        db.collection("attractionPoints").getDocuments(completion: { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
                complition(nil, err)
            } else {
                var product: [Place] = []
                for document in querySnapshot!.documents {
                    let featuresModel = Place(city: document.data()["city"] as! String, country: document.data()["country"] as! String, coordinates: document.data()["coordinates"] as! [Double], formatted: document.data()["formatted"] as! String, names: document.data()["names"] as! String)
                    product.append(featuresModel)
                }
                complition(product,nil)
            }
        })
    }
}
