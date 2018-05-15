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
import FirebaseAuth
import FirebaseDatabase

class User {
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    var profilePictureUrl:String?
    var schoolName:String?
    var school:School?
    var name:String {
        return firstName + " " + lastName
    }
    
    init(uid:String, firstName:String, lastName:String, email:String) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    init(user: FirebaseAuth.User, firstName: String, lastName: String) {
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
        schoolName = snapshotValue["school"] as? String
        
        if let sName = schoolName {
            getSchoolByName(name: sName) { (school) in
                self.school = school
            }
        }
    }
    
    
    func toAnyObject() -> Any {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "email": email
        ]
    }
}


extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}


extension User: Hashable {
    var hashValue: Int {
        return self.uid.hashValue
    }
}

