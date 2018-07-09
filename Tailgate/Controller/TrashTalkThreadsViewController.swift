//
//  TrashTalkThreadsViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 7/9/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class TrashTalkThreadsViewController: UIViewController {

    @IBOutlet weak var threadsTable: UITableView!
    
    var conferences:[String] = ["BIG 10", "BIG 12", "ACC", "PAC-12", "SEC"]
    var games:[String:[Game]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change font and color of nav header
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20.0),
            NSAttributedStringKey.foregroundColor: UIColor.steel
        ]

        self.threadsTable.delegate = self
        self.threadsTable.dataSource = self
        self.threadsTable.rowHeight = UITableViewAutomaticDimension
        
        // Get current games
        for conference in conferences {
            let conferenceKey = conference.lowercased().replacingOccurrences(of: " ", with: "")
            
            getCurrentGamesForConference(conferenceName: conferenceKey, completion: { (games) in
                self.games[conferenceKey] = games
                self.threadsTable.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



extension TrashTalkThreadsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}



extension TrashTalkThreadsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.conferences[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.conferences.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentConference = self.conferences[section]
        let conferenceKey = currentConference.lowercased().replacingOccurrences(of: " ", with: "")
        if let conferenceGames = self.games[conferenceKey] {
            return conferenceGames.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        let row = indexPath.row
        let section = indexPath.section
        
        let conference = self.conferences[section]
        let conferenceKey = conference.lowercased().replacingOccurrences(of: " ", with: "")
        let game = self.games[conferenceKey]![row]
        
        cell.textLabel?.text = game.awayTeam + " at " + game.homeTeam
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

}
