//
//  Configuration.swift
//  Tailgate
//
//  Created by Michael Onjack on 4/1/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

final class Configuration {
    private static let sharedConfiguration:Configuration = Configuration()
    
    var weekNum:Int!
    var week:String!
    var currentUser:User!
    var schoolCache:[String:School] = [:]
    
    private init() {
        // Default to cached values
        self.weekNum = UserDefaults.standard.value(forKey: "week") as? Int ?? 1
        self.week = "week" + String(weekNum)
        
        // Set the current week
        let configurationReference = Database.database().reference(withPath: "configuration")
        configurationReference.keepSynced(true)
        
        configurationReference.observe(.value) { (snapshot) in
            if let configDict = snapshot.value as? [String:AnyObject] {
                let weekNum = configDict["week"] as! Int
                self.week = "week" + String(weekNum)
                self.weekNum = weekNum
                
                // Cache the week number
                UserDefaults.standard.setValue(weekNum, forKey: "week")
            }
        }
        
        refreshSchoolCache { (schoolDict) in
            // Nothing needed, cache already refreshed
        }
        
        Auth.auth().addStateDidChangeListener { (auth, newUser) in
            // Set the current user
            if (Auth.auth().currentUser != nil) {
                let userReference = Database.database().reference(withPath: "users/" + getCurrentUserId())
                userReference.keepSynced(true)
                userReference.observe(.value) { (snapshot) in
                    self.currentUser = User(snapshot: snapshot)
                }
            }
        }
    }
    
    class func shared() -> Configuration {
        return sharedConfiguration
    }
}
