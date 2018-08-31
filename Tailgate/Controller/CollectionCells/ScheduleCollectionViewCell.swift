//
//  ScheduleCollectionViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit


struct GameCell {
    var game: Game
    var isExpanded: Bool
    
    init(game:Game) {
        self.game = game
        self.isExpanded = false
    }
}

class ScheduleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    var conferenceName = ""
    var games:[GameCell] = []
}



extension ScheduleCollectionViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.games[indexPath.row].isExpanded {
            self.games[indexPath.row].isExpanded = false
        } else {
            self.games[indexPath.row].isExpanded = true
        }
        
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let gameCell = self.games[indexPath.row]
        
        let tableViewWidth = tableView.bounds.width
        let detailLabelHeight = gameCell.game.score == "0 - 0" ?  gameCell.game.startTimeDisplayStr.height(withConstrainedWidth: tableViewWidth * 0.191136, font: UIFont.systemFont(ofSize: 12.0)) : gameCell.game.score.height(withConstrainedWidth: tableViewWidth * 0.191136, font: UIFont.systemFont(ofSize: 12.0))
        let teamsLabelHeight = (gameCell.game.awayTeam + " at " + gameCell.game.homeTeam).height(withConstrainedWidth: tableViewWidth * 0.747922, font: UIFont.systemFont(ofSize: 12.0))
        let awayTeamLabelHeight = gameCell.game.awayTeam.height(withConstrainedWidth: tableViewWidth * 0.3324, font: UIFont.systemFont(ofSize: 12.0))
        let homeTeamLabelHeight = gameCell.game.homeTeam.height(withConstrainedWidth: tableViewWidth * 0.3324, font: UIFont.systemFont(ofSize: 12.0))
        let teamLogoHeight:CGFloat = 80.0
        
        // Size of the teams label or detail label (whichever is bigger) plus the size of its top and bottom contraints
        let minimizedHeight = 11 + max(detailLabelHeight, teamsLabelHeight) + 12.5
        
        // Size of the minimizedHeight plus the size of the team logo plus the size of the logo bottom constraint plus the size of the away team label or the home team label (whichever is bigger) plus the label bottom constraint height
        let expandedHeight = minimizedHeight + teamLogoHeight + 11 + max(awayTeamLabelHeight, homeTeamLabelHeight) + 11
        
        if gameCell.isExpanded {
            return expandedHeight
        } else {
            return minimizedHeight
        }
    }
    
    
    
    func addRefreshControl() {
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            self.scheduleTableView.refreshControl = self.refreshControl
        } else {
            self.scheduleTableView.addSubview(self.refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshScheduleTable(_:)), for: .valueChanged)
    }
    
    
    @objc private func refreshScheduleTable(_ sender: Any) {
        let conferenceKey = self.conferenceName.lowercased().replacingOccurrences(of: " ", with: "")
        
        getCurrentGameCellsForConference(conferenceName: conferenceKey, completion: { (games) in
            self.games = games
            
            refreshSchoolCache(completion: { (schoolDict) in
                DispatchQueue.main.async {
                    self.scheduleTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            })
        })
    }
    
}



extension ScheduleCollectionViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableCell", for: indexPath) as! ScheduleTableViewCell
        
        // Reset the recycled cell's labels
        cell.teamsLabel.text = ""
        cell.detailLabel.text = ""
        cell.scoreLabel.text = "0 - 0"
        cell.awayTeamLabel.text = ""
        cell.homeTeamLabel.text = ""
        // Reset the cell's selection
        cell.setSelected(false, animated: false)
        // Reset the recycled cell's logos
        cell.homeTeamLogo.image = UIImage(named: "HomeTeamDefault")
        cell.awayTeamLogo.image = UIImage(named: "AwayTeamDefault")
        
        // Update constraints if they haven't already been updated in a previous dequeuing
        if cell.awayTeamLogoLeadingConstraint.constant == 35 {
            cell.awayTeamLogoLeadingConstraint.updateHorizontalConstantForViewWidth(view: self.superview!)
            cell.homeTeamLogoTrailingConstraint.updateHorizontalConstantForViewWidth(view: self.superview!)
        }
        
        let currGame = self.games[indexPath.row].game
        cell.teamsLabel.text = currGame.awayTeam + " at " + currGame.homeTeam
        cell.awayTeamLabel.text = currGame.awayTeam
        cell.homeTeamLabel.text = currGame.homeTeam
        cell.scoreLabel.text = currGame.score
        if currGame.score == "0 - 0" {
            cell.detailLabel.text = currGame.startTimeDisplayStr
        } else {
            cell.detailLabel.text = currGame.score
        }
        
        // Cached
        if !configuration.schoolCache.isEmpty {
            // Set away team logo
            if let school = configuration.schoolCache[currGame.awayTeam], let logoUrlStr = school.logoUrl {
                let logoUrl = URL(string: logoUrlStr)
                cell.awayTeamLogo.sd_setImage(with: logoUrl, completed: nil)
            }
            
            // Set home team logo
            if let school = configuration.schoolCache[currGame.homeTeam], let logoUrlStr = school.logoUrl {
                let logoUrl = URL(string: logoUrlStr)
                cell.homeTeamLogo.sd_setImage(with: logoUrl, completed: nil)
            }
        }
        
        // Not cached
        else {
            // Set away team logo
            getSchoolByTeamName(teamName: currGame.awayTeam) { (school) in
                if let school = school, let logoUrlStr = school.logoUrl {
                    let logoUrl = URL(string: logoUrlStr)
                    cell.awayTeamLogo.sd_setImage(with: logoUrl, completed: nil)
                }
            }
            
            // Set home team logo
            getSchoolByTeamName(teamName: currGame.homeTeam) { (school) in
                if let school = school, let logoUrlStr = school.logoUrl {
                    let logoUrl = URL(string: logoUrlStr)
                    cell.homeTeamLogo.sd_setImage(with: logoUrl, completed: nil)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.games.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.conferenceName + " SCHEDULE"
    }
}
