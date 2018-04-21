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
    
    init(name:String) {
        self.name = name
    }
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name = snapshotValue["name"] as! String
    }
}



extension School: Equatable {
    static func == (lhs: School, rhs: School) -> Bool {
        return lhs.name == rhs.name
    }
}
