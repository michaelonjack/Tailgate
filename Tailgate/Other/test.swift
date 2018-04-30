//
//  test.swift
//  Tailgate
//
//  Created by Michael Onjack on 4/1/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase

func doStuff() {
    // get the file path for the file "test.json" in the playground bundle
    let filePath = Bundle.main.path(forResource:"cfb_json", ofType: "txt")
    
    // get the contentData
    let contentData = FileManager.default.contents(atPath: filePath!)
    
    // get the string
    let content = String(data:contentData!, encoding:String.Encoding.utf8)
    
    let big10schools:[String] = [
        "Penn State Nittany Lions",
        "Ohio State Buckeyes",
        "Iowa Hawkeyes",
        "Purdue Boilermakers",
        "Michigan State Spartans",
        "Michigan Wolverines",
        "Northwestern Wildcats",
        "Illinois Fighting Illini",
        "Maryland Terrapins",
        "Minnesota Golden Gophers",
        "Nebraska Cornhuskers",
        "Wisconsin Badgers",
        "Indiana Hoosiers"
    ]
    
    let big12schools:[String] = [
        "Baylor Bears",
        "Iowa State Cyclones",
        "Kansas Jayhawks",
        "Kansas State Wildcats",
        "Oklahoma Sooners",
        "Oklahoma State Cowboys",
        "TCU Horned Frogs",
        "Texas Longhorns",
        "Texas Tech Red Raiders",
        "West Virginia Mountaineers"
    ]
    
    let secschools:[String] = [
        "Alabama Crimson Tide",
        "Arkansas Razorbacks",
        "Auburn Tigers",
        "Florida Gators",
        "Georgia Bulldogs",
        "Kentucky Wildcats",
        "LSU Tigers",
        "Mississippi State Bulldogs",
        "Missouri Tigers",
        "Ole Miss Rebels",
        "South Carolina Gamecocks",
        "Tennessee Volunteers",
        "Texas A&M Aggies",
        "Vanderbilt Commodores"
    ]
    
    let accschools:[String] = [
        "Boston College Eagles",
        "Clemson Tigers",
        "Duke Blue Devils",
        "Florida State Seminoles",
        "Georgia Tech Yellow Jackets",
        "Louisville Cardinals",
        "Miami Hurricanes",
        "NC State Wolfpack",
        "North Carolina Tar Heels",
        "Pittsburgh Panthers",
        "Syracuse Orange",
        "Virginia Cavaliers",
        "Virginia Tech Hokies",
        "Wake Forest Demon Deacons"
    ]
    
    let pac12schools:[String] = [
        "Arizona Wildcats",
        "Arizona State Sun Devils",
        "California Golden Bears",
        "Colorado Buffaloes",
        "Oregon Ducks",
        "Oregon State Beavers",
        "Stanford Cardinal",
        "UCLA Bruins",
        "USC Trojans",
        "Utah Utes",
        "Washington Huskies",
        "Washington State Cougars"
    ]
    
    let data = content!.data(using: .utf8)!
    do {
        if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
        {
            for dict in jsonArray {
                let homeTeam = dict["HomeTeamName"] as! String
                let awayTeam = dict["AwayTeamName"] as! String
                let day = dict["Day"] as! String
                let weekNum = dict["Week"] as! Int
                let week = "week" + String(dict["Week"] as! Int)
                
                let gameReference = Database.database().reference(withPath: "games/" + week + "/pac-12")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let date = dateFormatter.date(from:day)!
                
                if (pac12schools.contains(homeTeam) || pac12schools.contains(awayTeam)) {
                    let g = Game(homeTeam: homeTeam, awayTeam: awayTeam, startTime: date)
                    gameReference.child(g.id).setValue(g.toAnyObject())
                    //print(g.startTimeStr.replacingOccurrences(of: ", TBD", with: ""))
                    //print(homeTeam + " vs " + awayTeam )
                }
 
            }
        } else {
            print("bad json")
        }
    } catch let error as NSError {
        print(error)
    }
}
