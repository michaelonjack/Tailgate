//
//  Drink.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/23/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Drink {
    
    let id:String
    let name:String
    
    init(id:String, name:String) {
        self.id = id
        self.name = name
    }
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        id = snapshot.key
        name = snapshotValue["name"] as? String ?? ""
    }
    
}
