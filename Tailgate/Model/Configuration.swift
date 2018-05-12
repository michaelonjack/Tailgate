//
//  Configuration.swift
//  Tailgate
//
//  Created by Michael Onjack on 4/1/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import Firebase

final class Configuration {
    private static let sharedConfiguration:Configuration = Configuration()
    
    var week:String = "week1"
    var schoolCache: [String:School] = [:]
    
    private init() {
        // Set the current week
        let configurationReference = Database.database().reference(withPath: "configuration")
        configurationReference.keepSynced(true)
        
        configurationReference.observe(.value) { (snapshot) in
            if let configDict = snapshot.value as? [String:AnyObject] {
                let weekNum = configDict["week"] as! Int
                self.week = "week" + String(weekNum)
            }
        }
        
        refreshSchoolCache { (schoolDict) in
            // Nothing needed, cache already refreshed
        }
    }
    
    class func shared() -> Configuration {
        return sharedConfiguration
    }
}
