//
//  Tailgate.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/23/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import Foundation
import Firebase

class Tailgate {
    let id: String!
    let owner: String!
    let name: String!
    let school: School!
    let isPublic: Bool!
    let startTime: Date!
    let foods:[Food]!
    let drinks:[Drink]!
    let invites:[User]!
    
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
        
        let isPublic = snapshotValue["isPublic"] as? String ?? ""
        if isPublic == "true" {
            self.isPublic = true
        } else {
            self.isPublic = false
        }
    }
    
    func toAnyObject() -> Any {
        var foodDict: [String:String] = [:]
        var drinkDict: [String:String] = [:]
        
        for food in foods {
            foodDict["id"] = food.id
        }
        
        for drink in drinks {
            drinkDict["id"] = drink.id
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
            "drinks": drinkDict
        ]
    }
}
