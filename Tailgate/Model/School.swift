//
//  School.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/17/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import Foundation
import Firebase

class School {
    let name:String
    let teamName:String
    var logoUrl:String?
    
    init(name:String) {
        self.name = name
        self.teamName = name
    }
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name = snapshotValue["name"] as! String
        self.teamName = snapshotValue["teamName"] as! String
        self.logoUrl = snapshotValue["logoUrl"] as? String
    }
}



extension School: Equatable {
    static func == (lhs: School, rhs: School) -> Bool {
        return lhs.name == rhs.name
    }
}
