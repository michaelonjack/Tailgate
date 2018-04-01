//
//  Configuration.swift
//  Tailgate
//
//  Created by Michael Onjack on 4/1/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import Firebase

class Configuration {
    private static var sharedConfiguration:Configuration = {
        let configuration = Configuration()
        
        return configuration
    }()
    
    var week:String?
    
    private init() {
        let configurationReference = Database.database().reference(withPath: "configuration")
        configurationReference.keepSynced(true)
        
        configurationReference.observe(.value) { (snapshot) in
            if let configDict = snapshot.value as? [String:AnyObject] {
                let weekNum = configDict["week"] as! Int
                self.week = "week" + String(weekNum)
            } else {
                self.week = ""
            }
        }
    }
    
    class func shared() -> Configuration {
        return sharedConfiguration
    }
}
