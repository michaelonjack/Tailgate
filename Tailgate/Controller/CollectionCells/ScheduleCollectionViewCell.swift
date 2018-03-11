//
//  ScheduleCollectionViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class ScheduleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var scheduleTableVIew: UITableView!
    
    let sectionTitles = ["BIG 10 SCHEDULE"]
    var games:[Game] = []
}



extension ScheduleCollectionViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
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
        cell.teamsLabel.text = currGame.awayTeam + " vs. " + currGame.homeTeam
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.games.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
}
