//
//  School.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/17/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//
import Foundation
import FirebaseDatabase

class School {
    let name:String
    let teamName:String
    let isHidden:Bool
    var latitude: Double?
    var longitude: Double?
    var logoUrl:String?
    
    
    init(name:String) {
        self.name = name
        self.teamName = name
        self.isHidden = false
    }
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name = snapshotValue["name"] as! String
        self.teamName = snapshotValue["teamName"] as! String
        self.logoUrl = snapshotValue["logoUrl"] as? String
        self.latitude = snapshotValue["latitude"] as? Double
        self.longitude = snapshotValue["longitude"] as? Double
        
        let isHidden = snapshotValue["isHidden"] as? Int ?? 0
        if isHidden == 1 {
            self.isHidden = true
        } else {
            self.isHidden = false
        }
    }
}



extension School: Equatable {
    static func == (lhs: School, rhs: School) -> Bool {
        return lhs.name == rhs.name
    }
}
