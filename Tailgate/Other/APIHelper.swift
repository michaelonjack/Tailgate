//
//  APIHelper.swift
//  Tailgate
//
//  Created by Michael Onjack on 10/20/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct JSONGame: Decodable {
    let homeTeamScore: String
    let awayTeamScore:String
    let homeTeamName:String
    let awayTeamName:String
    let status:String
}

func updatesScores(forConference conference: String, forWeek week: Int, completion: @escaping ((Bool) -> Void)) {
    
    // Only update the scores for the current week
    if week != configuration.weekNum {
        completion(true)
        return
    }
    
    let UPDATE_INTERVAL = 15
    
    // We're restricting the live score updates to once every 15 minutes so do a check of when this conference's scores were last update
    getLastUpdatedDate(forConference: conference, forWeek: week, completion: { (lastUpdatedDate) in
        
        if let lastUpdatedDate = lastUpdatedDate {
            if let minutesSinceLastUpdate =  Calendar.current.dateComponents([.minute], from: lastUpdatedDate, to: Date()).minute {
                
                // If it has been less that 15 minutes since the last update, return
                if minutesSinceLastUpdate < UPDATE_INTERVAL {
                    completion(true)
                    return;
                }
            }
        }
        
        let urlStr = "https://michaelonjack.com/tailgator?week=" + String(week) + "&conference=" + conference.replacingOccurrences(of: "-", with: "")
        let url = URL(string: urlStr)!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                completion(false)
                return
            }
            
            guard let data = data else { completion(false); return; }
            
            do {
                let jsonData:[JSONGame] = try JSONDecoder().decode([JSONGame].self, from: data)
            
                getGames(forConference: conference, forWeek: week, completion: { (games) in
                    for jsonGame in jsonData {
                        
                        for game in games {
                            if (game.awayTeam.range(of: jsonGame.awayTeamName) != nil) && (game.homeTeam.range(of: jsonGame.homeTeamName) != nil) {
                                
                                game.awayTeamScore = Int(jsonGame.awayTeamScore) ?? 0
                                game.homeTeamScore = Int(jsonGame.homeTeamScore) ?? 0
                                game.status = jsonGame.status
                                let gameReference = Database.database().reference(withPath: "games/" + configuration.season + "/week" + String(week) + "/" + conference)
                                gameReference.updateChildValues([game.id : game.toAnyObject()])
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                gameReference.updateChildValues(["lastUpdated" : dateFormatter.string(from: Date())])
                                
                                break
                            }
                        }
                    }
                    
                    completion(true)
                })
                
            } catch let jsonError {
                print(jsonError)
                completion(false)
            }
        }.resume()
    })
    
    completion(false)
}
