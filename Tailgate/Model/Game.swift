//
//  Game.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Game {
    let id:String
    let homeTeam:String
    let awayTeam:String
    let homeTeamScore:Int
    let awayTeamScore:Int
    let startTime:Date?
    var score:String {
        let scoreStr = String(awayTeamScore) + " - " + String(homeTeamScore)
        return scoreStr
    }
    var startTimeDisplayStr:String {
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
    var startTimeDatabaseStr:String {
        if let startTime = self.startTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return formatter.string(from: startTime)
        } else {
            return ""
        }
    }
    
    init(id:String, homeTeam:String, awayTeam:String, startTime:Date, score:String) {
        self.id = id
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.startTime = startTime
        self.awayTeamScore = 0
        self.homeTeamScore = 0
    }
    
    init(homeTeam:String, awayTeam:String, startTime:Date) {
        self.id = UUID().uuidString
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.startTime = startTime
        self.homeTeamScore = 0
        self.awayTeamScore = 0
    }
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.id = snapshot.key
        self.homeTeam = snapshotValue["homeTeam"] as! String
        self.awayTeam = snapshotValue["awayTeam"] as! String
        self.homeTeamScore = snapshotValue["homeTeamScore"] as? Int ?? 0
        self.awayTeamScore = snapshotValue["awayTeamScore"] as? Int ?? 0
        
        let startTimeStr = snapshotValue["startTime"] as? String ?? ""
        
        if startTimeStr == "" {
            self.startTime = nil
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            self.startTime = dateFormatter.date(from: startTimeStr)
        }
    }
    
    func toAnyObject() -> Any {
        return [
            "awayTeam": awayTeam,
            "homeTeam": homeTeam,
            "startTime": startTimeDatabaseStr,
            "homeTeamScore": homeTeamScore,
            "awayTeamScore": awayTeamScore
        ]
    }
}
