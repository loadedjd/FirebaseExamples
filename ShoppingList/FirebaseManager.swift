//
//  FirebaseManager.swift
//  ShoppingList
//
//  Created by Jared Williams on 2/27/18.
//  Copyright © 2018 Jared Williams. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseCore

class FirebaseManager {
    
    static let sharedInstance = FirebaseManager() // This is called a singleton
    
    var database = Database.database().reference() //Reference to the root of our database
    var mostRecentItems = [String: String]()
    
    private func getArbitraryDataFrom(child: String, completion: ((Any?)->())?) {
        
        // The .value basically says get all the data from the reciever of this call
        self.database.child(child).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            completion?(snapshot.value)
        }
        
    }
    
    func getDictionaryFromRemote(child: String, completion: (([String: String]?)->())?) {
        
        self.getArbitraryDataFrom(child: child) { (data: Any?) in
            if let unwrappedData = data as? [String : String] {
                completion?(unwrappedData)
            } else {
                completion?(nil)
            }
        }
    }
    
    func pushDictionaryToRemote(data: [String : String], child: String,  autoId: Bool) {
        
        if autoId {
            self.database.child(child).childByAutoId().setValue(data)
        } else {
            self.database.child(child).setValue(data)
        }
        
    }
    
    func getAllItems() {
        self.getArbitraryDataFrom(child: "items") { (data: Any?) in
            
            var items = [String : String]()
            
        guard let dataDictionary = data as? [String : [String : String]] else { return }
            
        print(dataDictionary)
            
            for child in dataDictionary {
                let itemDictionary = child.value
                items[child.key] = (itemDictionary["Item"]!)
            }
            
            self.mostRecentItems = items
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadData")))
        }
    }
    
    func deleteChild(path: String) {
        self.database.child(path).removeValue()
    }
    
    
}
