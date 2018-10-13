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
    @IBOutlet weak var weekButton: UIButton!
    
    let refreshControl = UIRefreshControl()
    var rankings:[Int:School] = [:]
    var selectedWeek: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rankingsTable.delegate = self
        rankingsTable.dataSource = self
        rankingsTable.rowHeight = UITableView.automaticDimension
        rankingsTable.allowsSelection = false
        rankingsTable.estimatedRowHeight = 90
        rankingsTable.layer.cornerRadius = 10
        addRefreshControl()

        getRankings { (rankings) in
            self.rankings = rankings
            
            DispatchQueue.main.async {
                self.rankingsTable.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            if let selectedWeek = self.selectedWeek {
                self.weekButton.setTitle("Week " + String(selectedWeek), for: .normal)
            } else {
                self.weekButton.setTitle("Week " + String(configuration.weekNum), for: .normal)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RankingsToWeekPickerPopup" {
            guard let popupController = segue.destination as? PickerPopupViewController else {return}
            
            var values:[String] = []
            for i in 1..<configuration.weekNum+1 {
                values.append("Week " + String(i))
            }
            
            popupController.values = values
            if let selectedWeek = self.selectedWeek {
                popupController.initialIndex = selectedWeek-1
            } else {
                popupController.initialIndex =  configuration.weekNum-1
            }
            popupController.pickerPopupDelegate = self
        }
    }

}



extension GamedayRankingsViewController: PickerPopupDelegate {
    func selectPressed(popupController: PickerPopupViewController, selectedIndex: Int, selectedValue: String) {
        
        // Update the week button label to show the selected value
        DispatchQueue.main.async {
            popupController.dismiss(animated: true, completion: nil)
            self.weekButton.setTitle(selectedValue, for: .normal)
        }
        
        selectedWeek = selectedIndex + 1
        
        // Get the rankings for the selected week
        getRankings(forWeek: selectedWeek!) { (rankings) in
            self.rankings = rankings
            
            DispatchQueue.main.async {
                self.rankingsTable.reloadData()
            }
        }
    }
}



extension GamedayRankingsViewController: UITableViewDelegate {
    func addRefreshControl() {
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            self.rankingsTable.refreshControl = self.refreshControl
        } else {
            self.rankingsTable.addSubview(self.refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshRankingsTableView(_:)), for: .valueChanged)
    }
    
    @objc private func refreshRankingsTableView(_ sender: Any) {
        // Update rankings
        getRankings(forWeek: selectedWeek ?? configuration.weekNum) { (rankings) in
            self.rankings = rankings
            
            DispatchQueue.main.async {
                self.rankingsTable.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
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
        
        // Update the leading constraint width for the screen size
        if cell.rankLabelLeadingConstraint.constant == 10 {
                cell.rankLabelLeadingConstraint.updateHorizontalConstantForViewWidth(view: cell.contentView)
        }
        
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
