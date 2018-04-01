//
//  Game.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import Firebase

class Game {
    let id:String
    let homeTeam:String
    let awayTeam:String
    let score:String
    let startTime:Date?
    var startTimeStr:String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        
        if let startTime = self.startTime {
            let hour = calendar.component(.hour, from: startTime)
            let minutes = calendar.component(.minute, from: startTime)
            
            dateFormatter.dateFormat = "EEEE, MMM d, h:mm a"
            let dateStringLong = dateFormatter.string(from: startTime)
            dateFormatter.dateFormat = "EEEE, MMM d"
            let dateStringShort = dateFormatter.string(from: startTime) + ", TBD"

            if hour == 0 && minutes == 0 {
                return dateStringShort
            } else {
                return dateStringLong
            }
        } else {
            return "TBD"
        }
    }
    
    init(id:String, homeTeam:String, awayTeam:String, startTime:Date, score:String) {
        self.id = id
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.startTime = startTime
        self.score = score
    }
    
    init(homeTeam:String, awayTeam:String, startTime:Date) {
        self.id = UUID().uuidString
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.startTime = startTime
        self.score = ""
    }
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.id = snapshot.key
        self.homeTeam = snapshotValue["homeTeam"] as! String
        self.awayTeam = snapshotValue["awayTeam"] as! String
        self.score = snapshotValue["score"] as? String ?? ""
        
        let startTimeStr = snapshotValue["startTime"] as? String ?? ""
        let dateFormatter = DateFormatter()
        if startTimeStr.contains(":") {
            dateFormatter.dateFormat = "EEEE, MMM d, h:mm a"
            self.startTime = dateFormatter.date(from: startTimeStr)
        } else if startTimeStr.contains(",") {
            dateFormatter.dateFormat = "EEEE, MMM d"
            self.startTime = dateFormatter.date(from: startTimeStr)
        } else {
            self.startTime = nil
        }
    }
    
    func toAnyObject() -> Any {
        return [
            "awayTeam": awayTeam,
            "homeTeam": homeTeam,
            "startTime": startTimeStr
        ]
    }
}
