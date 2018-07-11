//
//  School.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/17/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//
import Foundation
import FirebaseDatabase
import SDWebImage

class School {
    let name:String
    let teamName:String
    let isHidden:Bool
    var logoUrl:String?
    var logoImageView: UIImageView
    
    init(name:String) {
        self.name = name
        self.teamName = name
        self.isHidden = false
        self.logoImageView = UIImageView()
    }
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name = snapshotValue["name"] as! String
        self.teamName = snapshotValue["teamName"] as! String
        self.logoUrl = snapshotValue["logoUrl"] as? String
        self.logoImageView = UIImageView()
        
        let isHidden = snapshotValue["isHidden"] as? Int ?? 0
        if isHidden == 1 {
            self.isHidden = true
        } else {
            self.isHidden = false
        }
        
        if let logoUrl = self.logoUrl {
            let url = URL(string: logoUrl)
            self.logoImageView.sd_setImage(with: url, completed: nil)
        }
    }
}



extension School: Equatable {
    static func == (lhs: School, rhs: School) -> Bool {
        return lhs.name == rhs.name
    }
}
