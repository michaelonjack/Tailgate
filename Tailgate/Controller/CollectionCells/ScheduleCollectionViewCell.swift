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
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
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
        print(conferenceKey)
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
        cell.teamsLabel.text = ""
        cell.detailLabel.text = ""
        // Reset the cell's selection
        cell.setSelected(false, animated: false)
        
        let currGame = self.games[indexPath.row]
        cell.teamsLabel.text = currGame.awayTeam + " at " + currGame.homeTeam
        if currGame.score == "" {
            cell.detailLabel.text = currGame.startTimeStr
        } else {
            cell.detailLabel.text = currGame.score
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
