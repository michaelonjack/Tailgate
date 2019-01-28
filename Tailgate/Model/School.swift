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
    var logoUrl: String?
    var primaryColor: UIColor?
    var secondaryColor: UIColor?
    var backgroundColor: UIColor?
    
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
        
        if let colors = snapshotValue["colors"] as? [String: AnyObject] {
            if let primary = colors["primary"] as? [String: AnyObject] {
                self.primaryColor = UIColor(red: primary["r"] as? CGFloat ?? 0.0, green: primary["g"] as? CGFloat ?? 0.0, blue: primary["b"] as? CGFloat ?? 0.0, alpha: primary["alpha"] as? CGFloat ?? 0.0)
            }
            
            if let secondary = colors["secondary"] as? [String: AnyObject] {
                self.secondaryColor = UIColor(red: secondary["r"] as? CGFloat ?? 0.0, green: secondary["g"] as? CGFloat ?? 0.0, blue: secondary["b"] as? CGFloat ?? 0.0, alpha: secondary["alpha"] as? CGFloat ?? 0.0)
            }
            
            if let background = colors["background"] as? [String: AnyObject] {
                self.backgroundColor = UIColor(red: background["r"] as? CGFloat ?? 0.0, green: background["g"] as? CGFloat ?? 0.0, blue: background["b"] as? CGFloat ?? 0.0, alpha: background["alpha"] as? CGFloat ?? 0.0)
            }
        }
        
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
