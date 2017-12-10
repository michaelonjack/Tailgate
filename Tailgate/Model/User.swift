//
//  User.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/10/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

//Structure of User:
//  {
//      "user": {
//          **uid**: {
//              "firstName": ____,
//              "lastName": _____,
//              "email": _____
//          }
//      }
//  }

import Foundation
import Firebase

class User {
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    var profilePictureUrl:String?
    var name:String {
        return firstName + " " + lastName
    }
    
    init(uid:String, firstName:String, lastName:String, email:String) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    init(user: Firebase.User, firstName: String, lastName: String) {
        self.uid = user.uid
        self.email = user.email!
        self.firstName = firstName
        self.lastName = lastName
    }
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        uid = snapshot.key
        firstName = snapshotValue["firstName"] as! String
        lastName = snapshotValue["lastName"] as! String
        email = snapshotValue["email"] as! String
        profilePictureUrl = snapshotValue["profilePictureUrl"] as? String
    }
    
    
    func toAnyObject() -> Any {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "email": email
        ]
    }
}
