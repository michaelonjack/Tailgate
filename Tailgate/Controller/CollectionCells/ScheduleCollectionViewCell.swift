//
//  ScheduleCollectionViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class ScheduleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    var conferenceName = ""
    var games:[Game] = []
    var parentViewController:GamedayScheduleViewController!
}



extension ScheduleCollectionViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ScheduleTableViewCell else { return }
        
        if cell.blurDetailView.alpha == 0 {
            UIView.animate(withDuration: 0.5) {
                tableView.visibleCells.forEach({ (tableCell) in
                    if let scheduleCell = tableCell as? ScheduleTableViewCell {
                        scheduleCell.blurDetailView.alpha = 0
                        scheduleCell.detailStackView.alpha = 0
                    }
                })
                
                cell.blurDetailView.alpha = 1
                cell.detailStackView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                cell.blurDetailView.alpha = 0
                cell.detailStackView.alpha = 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
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
        
        updatesScores(forConference: conferenceKey, forWeek: self.parentViewController.selectedWeek ?? configuration.weekNum) { (success) in
            getGames(forConference: conferenceKey, forWeek: self.parentViewController.selectedWeek ?? configuration.weekNum, completion: { (games) in
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
    
}



extension ScheduleCollectionViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableCell", for: indexPath) as! ScheduleTableViewCell
        
        // Reset the recycled cell's labels
        cell.teamsLabel.text = ""
        cell.detailLabel.text = ""
        cell.gameLink.setTitle("View", for: .normal)
        cell.gameLink.tag = indexPath.row
        cell.gameLink.addTarget(self, action: #selector(gameLinkPressed), for: .touchUpInside)
        
        // Reset the recycled cell's logos
        cell.homeTeamLogo.image = UIImage(named: "HomeTeamDefault")
        cell.awayTeamLogo.image = UIImage(named: "AwayTeamDefault")
        
        let currGame = self.games[indexPath.row]
        cell.teamsLabel.text = currGame.awayTeam + " at " + currGame.homeTeam
        cell.gameLink.setTitle(currGame.status == "" ? "View" : currGame.status, for: .normal)
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
    
    @objc func gameLinkPressed(_ sender: UIButton) {
        guard let cell = scheduleTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? ScheduleTableViewCell else { return }
        
        if let teamsStr = cell.teamsLabel.text {
            let gameLink = "https://www.google.com/search?q=" + teamsStr.replacingOccurrences(of: " ", with: "%20") + "%20football"
            guard let gameUrl = URL(string: gameLink) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(gameUrl) {
                UIApplication.shared.open(gameUrl, options: [:])
            }
        }
    }
}
