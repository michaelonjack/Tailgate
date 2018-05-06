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
}



extension ScheduleCollectionViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ScheduleTableViewCell
        
        if cell.isExpanded {
            cell.isExpanded = false
        } else {
            cell.isExpanded = true
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let cell = tableView.cellForRow(at: indexPath) as? ScheduleTableViewCell {
            if cell.isExpanded {
                return cell.expandedHeight
            } else {
                return cell.minimizedHeight
            }
        }
        return 44.0
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
        
        getCurrentGamesForConference(conferenceName: conferenceKey, completion: { (games) in
            self.games = games
            self.scheduleTableView.reloadData()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
}



extension ScheduleCollectionViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableCell", for: indexPath) as! ScheduleTableViewCell
        
        // Reset the recycled cell's labels
        cell.isExpanded = false
        cell.teamsLabel.text = ""
        cell.detailLabel.text = ""
        cell.awayTeamLabel.text = ""
        cell.homeTeamLabel.text = ""
        // Reset the cell's selection
        cell.setSelected(false, animated: false)
        // Reset the recycled cell's logos
        cell.homeTeamLogo.image = UIImage(named: "HomeTeamDefault")
        cell.awayTeamLogo.image = UIImage(named: "AwayTeamDefault")
        
        let currGame = self.games[indexPath.row]
        cell.teamsLabel.text = currGame.awayTeam + " at " + currGame.homeTeam
        cell.awayTeamLabel.text = currGame.awayTeam
        cell.homeTeamLabel.text = currGame.homeTeam
        if currGame.score == "" {
            cell.detailLabel.text = currGame.startTimeDisplayStr
        } else {
            cell.detailLabel.text = currGame.score
        }
        
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
