//
//  Tailgate.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/23/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreLocation

class Tailgate {
    let id: String!
    let ownerId: String!
    var name: String!
    var school: School!
    var isPublic: Bool!
    var startTime: Date!
    var owner: User?
    var location: CLLocation?
    var supplies:[Supply]!
    var invites:[User]! {
        didSet {
            // Each time the invites list is updated we need to be sure to update the invites list of any removed invites
            if let oldInvitesList = oldValue {
                let set1 = Set<User>(oldInvitesList)
                let set2 = Set<User>(invites)
                
                // Get all users in set1 that are not in set2
                let diff = set1.subtracting(set2)
                
                let removedInvites:[User] =  Array(diff)
                for removedInvite in removedInvites {
                    let userInviteReference = Database.database().reference(withPath: "users/" + removedInvite.uid + "/invites/" + self.id)
                    userInviteReference.removeValue()
                }
            }
        }
    }
    var flairImageUrl:String!
    var startTimeStr:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: self.startTime)
    }
    var startTimeDatabaseStr:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self.startTime)
    }
    
    init(ownerId:String, name:String, school:School, flairImageUrl:String, isPublic:Bool, startTime:Date, supplies:[Supply], invites:[User]) {
        
        self.ownerId = ownerId
        self.id = UUID().uuidString
        self.name = name
        self.school = school
        self.isPublic = isPublic
        self.startTime = startTime
        self.supplies = supplies
        self.invites = invites
        self.flairImageUrl = flairImageUrl
        self.location = nil
        
        getUserById(userId: self.ownerId) { (owner) in
            self.owner = owner
        }
    }
    
    init(snapshot:DataSnapshot) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.id = snapshot.key
        self.name = snapshotValue["name"] as? String ?? ""
        self.ownerId = snapshotValue["owner"] as? String ?? ""
        self.flairImageUrl = snapshotValue["flairImageUrl"] as? String ?? ""
        self.startTime = formatter.date(from: snapshotValue["startTime"] as? String ?? "")
        self.school = School(name: snapshotValue["school"] as? String ?? "")
        self.supplies = []
        self.invites = []
        self.location = nil
        
        let isPublic = snapshotValue["isPublic"] as? Int ?? 0
        if isPublic == 1 {
            self.isPublic = true
        } else {
            self.isPublic = false
        }
        
        // Get the users for invites
        if let inviteIds = snapshotValue["invites"] as? NSDictionary {
            for (_,id) in inviteIds {
                let id = id as? String ?? ""
                getUserById(userId: id, completion: { (user) in
                    self.invites.append(user)
                })
            }
        }
        
        if let supplies = snapshotValue["supplies"] as? NSDictionary {
            for (supplyId, supplyData) in supplies {
                if let supplyData = supplyData as? NSDictionary {
                    let supplyId:String = supplyId as? String ?? ""
                    let supplyName:String = supplyData["name"] as? String ?? ""
                    let supplier:String = supplyData["supplier"] as? String ?? ""
                    
                    let s = Supply(id: supplyId, name: supplyName, supplier: supplier)
                    self.supplies.append(s)
                }
            }
        }
        
        // Get the location of the tailgate by creating a CLLocation from the saved coordinates
        let latitude = snapshotValue["latitude"] as? Double
        let longitude = snapshotValue["longitude"] as? Double
        
        if let lat = latitude, let long = longitude {
            self.location = CLLocation(latitude: lat, longitude:long)
        }
        
        // Get the user with the stored id
        getUserById(userId: self.ownerId) { (owner) in
            self.owner = owner
        }
    }
    
    func toAnyObject() -> Any {
        var suppliesDict: [String:Any] = [:]
        var inviteDict: [String:String] = [:]
        
        for supply in supplies {
            suppliesDict[supply.id] = supply.toAnyObject()
        }
        
        for invite in invites {
            inviteDict["id"] = invite.uid
        }
        
        return [
            "owner": ownerId,
            "name": name,
            "school": school.name,
            "isPublic": isPublic,
            "flairImageUrl": flairImageUrl,
            "startTime": startTimeDatabaseStr,
            "supplies": suppliesDict,
            "invites": inviteDict
        ]
    }
    
    func isUserInvited(userId:String) -> Bool {
        for invite in self.invites {
            if userId == invite.uid {
                return true
            }
        }
        
        return false
    }
    
    func isOwner(userId:String) -> Bool {
        return userId == self.ownerId
    }
}



extension Tailgate: Equatable {
    static func == (lhs: Tailgate, rhs: Tailgate) -> Bool {
        return lhs.id == rhs.id
    }
}


extension Tailgate: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id.hashValue)
    }
}
