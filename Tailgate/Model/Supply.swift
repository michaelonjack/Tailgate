//
//  Supply.swift
//  Tailgate
//
//  Created by Michael Onjack on 5/11/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Supply {
    let id:String
    let name:String
    let supplier:String
    
    init(name:String, supplier:String) {
        self.id = UUID().uuidString
        self.name = name
        self.supplier = supplier
    }
    
    init(id:String, name:String, supplier:String) {
        self.id = id
        self.name = name
        self.supplier = supplier
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.id = snapshot.key
        self.name = snapshotValue["name"] as? String ?? ""
        self.supplier = snapshotValue["supplier"] as? String ?? ""
    }
    
    func toAnyObject() -> Any {
        return [
            "name": self.name,
            "supplier": self.supplier
        ]
    }
}
