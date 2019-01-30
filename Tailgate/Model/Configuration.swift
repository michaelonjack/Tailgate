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
    private let DEFAULT_WEEK: Int = 1
    private let DEFAULT_SEASON: String = "2019"
    
    var weekNum: Int!
    var week: String!
    var season: String!
    var currentUser: User!
    var schoolCache: [String:School] = [:]
    
    private init() {
        // Default to cached values
        self.season = UserDefaults.standard.value(forKey: "season") as? String ?? DEFAULT_SEASON
        self.weekNum = UserDefaults.standard.value(forKey: "week") as? Int ?? DEFAULT_WEEK
        self.week = "week" + String(weekNum)
        
        // Set the current week
        let configurationReference = Database.database().reference(withPath: "configuration")
        configurationReference.keepSynced(true)
        
        configurationReference.observe(.value) { (snapshot) in
            if let configDict = snapshot.value as? [String:AnyObject] {
                let weekNum = configDict["week"] as? Int ?? self.DEFAULT_WEEK
                let season = configDict["season"] as? String ?? self.DEFAULT_SEASON
                
                self.week = "week" + String(weekNum)
                self.weekNum = weekNum
                self.season = season
                
                // Cache the week number and season year
                UserDefaults.standard.setValue(weekNum, forKey: "week")
                UserDefaults.standard.setValue(season, forKey: "season")
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
