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
    
    var week:String = "week1"
    var weekNum:Int = 1
    var currentUser:User!
    var schoolCache:[String:School] = [:]
    
    private init() {
        // Set the current week
        let configurationReference = Database.database().reference(withPath: "configuration")
        configurationReference.keepSynced(true)
        
        configurationReference.observe(.value) { (snapshot) in
            if let configDict = snapshot.value as? [String:AnyObject] {
                let weekNum = configDict["week"] as! Int
                self.week = "week" + String(weekNum)
                self.weekNum = weekNum
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
