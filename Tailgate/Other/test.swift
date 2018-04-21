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
                
                let gameReference = Database.database().reference(withPath: "games/" + week + "/big10")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                //dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let date = dateFormatter.date(from:day)!
                
                /*
                if (big10schools.contains(homeTeam) || big10schools.contains(awayTeam)) && weekNum > 1 {
                    let g = Game(homeTeam: homeTeam, awayTeam: awayTeam, startTime: date)
                    //gameReference.child(g.id).setValue(g.toAnyObject())
                }
 */
                print(homeTeam + " vs " + awayTeam )
            }
        } else {
            print("bad json")
        }
    } catch let error as NSError {
        print(error)
    }
}
