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
    var blockedUserIds:[String] = []
    var blockedByUserIds:[String] = []
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
        
        // Get the users this user has blocked
        if let blockUserIds = snapshotValue["blocked"] as? NSDictionary {
            for (_,id) in blockUserIds {
                let id = id as? String ?? ""
                self.blockedUserIds.append(id)
            }
        }
        
        // Get the users that have blocked this user
        if let blockedByUserIds = snapshotValue["blockedBy"] as? NSDictionary {
            for (_,id) in blockedByUserIds {
                let id = id as? String ?? ""
                self.blockedByUserIds.append(id)
            }
        }
        
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
    
    
    
    // Returns true if the user with user id userId is blocked by the current user
    func blocksUser(withId userId:String) -> Bool {
        return self.blockedUserIds.contains(userId)
    }
    
    
    
    // Returns true if the user with user id userId has blocked the current user
    func blockedByUser(withId userId:String) -> Bool {
        return self.blockedByUserIds.contains(userId)
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

