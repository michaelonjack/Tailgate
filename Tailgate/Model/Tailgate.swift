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
    let owner: String!
    let name: String!
    let school: School!
    let isPublic: Bool!
    let startTime: Date!
    var location: CLLocation?
    var foods:[Food]!
    var drinks:[Drink]!
    var invites:[User]!
    
    init(owner:String, name:String, school:School, isPublic:Bool, startTime:Date, foods:[Food], drinks:[Drink], invites:[User]) {
        
        self.owner = owner
        self.id = UUID().uuidString
        self.name = name
        self.school = school
        self.isPublic = isPublic
        self.startTime = startTime
        self.foods = foods
        self.drinks = drinks
        self.invites = invites
        self.location = nil
    }
    
    init(snapshot:DataSnapshot) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.id = snapshot.key
        self.name = snapshotValue["name"] as? String ?? ""
        self.owner = snapshotValue["owner"] as? String ?? ""
        self.startTime = formatter.date(from: snapshotValue["startTime"] as? String ?? "")
        self.school = School(name: snapshotValue["school"] as? String ?? "")
        self.drinks = []
        self.foods = []
        self.invites = []
        self.location = nil
        
        let isPublic = snapshotValue["isPublic"] as? String ?? ""
        if isPublic == "true" {
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
        let drinkIds = snapshotValue["drinks"] as! NSDictionary
        for (_,id) in drinkIds {
            let id = id as? String ?? ""
            getDrinkById(drinkId: id, completion: { (drink) in
                self.drinks.append(drink)
            })
        }
        
        // Get the food by their saved ids
        let foodIds = snapshotValue["food"] as! NSDictionary
        for (_,id) in foodIds {
            let id = id as? String ?? ""
            getFoodById(foodId: id, completion: { (food) in
                self.foods.append(food)
            })
        }
        
        // Get the location of the tailgate by creating a CLLocation from the saved coordinates
        let latitude = snapshotValue["latitude"] as? Double
        let longitude = snapshotValue["longitude"] as? Double
        
        if let lat = latitude, let long = longitude {
            self.location = CLLocation(latitude: lat, longitude:long)
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
            "owner": owner,
            "name": name,
            "school": school.name,
            "isPublic": isPublic,
            "startTime": startTimeStr,
            "food": foodDict,
            "drinks": drinkDict,
            "invites": inviteDict
        ]
    }
}
