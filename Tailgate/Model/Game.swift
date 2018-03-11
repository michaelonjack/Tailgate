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
    let homeTeam:String
    let awayTeam:String
    let startTime:Date
    let score:String
    
    init(homeTeam:String, awayTeam:String, startTime:Date, score:String) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.startTime = startTime
        self.score = score
    }
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.homeTeam = snapshotValue["homeTeam"] as! String
        self.awayTeam = snapshotValue["awayTeam"] as! String
        self.score = snapshotValue["score"] as? String ?? ""
        
        self.startTime = snapshotValue["name"] as! Date
    }
}
