//
//  GamedayRankingsViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 9/24/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import SDWebImage

class GamedayRankingsViewController: UIViewController {

    @IBOutlet weak var rankingsTable: UITableView!
    
    var rankings:[Int:School] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rankingsTable.delegate = self
        rankingsTable.dataSource = self
        rankingsTable.rowHeight = UITableView.automaticDimension
        rankingsTable.allowsSelection = false
        rankingsTable.estimatedRowHeight = 90
        rankingsTable.layer.cornerRadius = 10

        getRankings { (rankings) in
            self.rankings = rankings
            
            DispatchQueue.main.async {
                self.rankingsTable.reloadData()
            }
        }
    }

}



extension GamedayRankingsViewController: UITableViewDelegate {

}



extension GamedayRankingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "AP Poll Top 25"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rankings.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingTableCell", for: indexPath) as! RankingsTableViewCell
        
        // Reset elements
        cell.rankLabel.text = ""
        cell.schoolNameLabel.text = ""
        cell.schoolLogo.image = UIImage(named: "AwayTeamDefault")
        
        
        let rank = indexPath.row + 1
        let school = self.rankings[rank]
        
        cell.rankLabel.text = String(rank)
        cell.schoolNameLabel.text = school?.teamName
        if let logoUrlStr = school?.logoUrl {
            let logoUrl = URL(string: logoUrlStr)
            cell.schoolLogo.sd_setImage(with: logoUrl, completed: nil)
        }
        
        return cell
    }
}
