//
//  Tailgate.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/23/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class Tailgate {
    let id: String!
    let ownerId: String!
    let name: String!
    let school: School!
    let isPublic: Bool!
    let startTime: Date!
    var owner: User?
    var location: CLLocation?
    var foods:[Food]!
    var drinks:[Drink]!
    var invites:[User]!
    var flairImageUrl:String!
    
    init(ownerId:String, name:String, school:School, flairImageUrl:String, isPublic:Bool, startTime:Date, foods:[Food], drinks:[Drink], invites:[User]) {
        
        self.ownerId = ownerId
        self.id = UUID().uuidString
        self.name = name
        self.school = school
        self.isPublic = isPublic
        self.startTime = startTime
        self.foods = foods
        self.drinks = drinks
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
        self.drinks = []
        self.foods = []
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
        
        // Get the drinks by their saved ids
        if let drinkIds = snapshotValue["drinks"] as? NSDictionary {
            for (_,id) in drinkIds {
                let id = id as? String ?? ""
                getDrinkById(drinkId: id, completion: { (drink) in
                    self.drinks.append(drink)
                })
            }
        }
        
        // Get the food by their saved ids
        if let foodIds = snapshotValue["food"] as? NSDictionary {
            for (_,id) in foodIds {
                let id = id as? String ?? ""
                getFoodById(foodId: id, completion: { (food) in
                    self.foods.append(food)
                })
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
        var foodDict: [String:String] = [:]
        var drinkDict: [String:String] = [:]
        var inviteDict: [String:String] = [:]
        
        for food in foods {
            foodDict["id"] = food.id
        }
        
        for drink in drinks {
            drinkDict["id"] = drink.id
        }
        
        for invite in invites {
            inviteDict["id"] = invite.uid
        }
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startTimeStr = formatter.string(from: startTime)
        
        return [
            "owner": ownerId,
            "name": name,
            "school": school.name,
            "isPublic": isPublic,
            "flairImageUrl": flairImageUrl,
            "startTime": startTimeStr,
            "food": foodDict,
            "drinks": drinkDict,
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
}



extension Tailgate: Equatable {
    static func == (lhs: Tailgate, rhs: Tailgate) -> Bool {
        return lhs.id == rhs.id
    }
}


extension Tailgate: Hashable {
    var hashValue: Int {
        return self.id.hashValue
    }
}
