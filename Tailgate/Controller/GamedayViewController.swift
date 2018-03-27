//
//  GamedayViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class GamedayViewController: UIViewController {

    @IBOutlet weak var schedulesCollectionView: UICollectionView!
    
    var conferences = ["BIG 10", "SEC"]
    var games:[String:[Game]] = [:]
    var collectionViewCurrentIndex:Int {
        return Int(self.schedulesCollectionView.contentOffset.x / self.schedulesCollectionView.frame.size.width)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schedulesCollectionView.delegate = self
        schedulesCollectionView.dataSource = self
        
        // Change font and color of nav header
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22.0), NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        
        // Get current games
        for conference in conferences {
            let conferenceKey = conference.lowercased().replacingOccurrences(of: " ", with: "")
            
            getCurrentGamesForConference(conferenceName: conferenceKey, completion: { (games) in
                self.games[conferenceKey] = games
                self.schedulesCollectionView.reloadItems(at: [IndexPath(item: self.games.count-1, section: 0)])
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



extension GamedayViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}



extension GamedayViewController: UICollectionViewDataSource {
    // There’s one search per section, so the number of sections is the count of the searches array
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCollectionViewCell
        
        let conferenceName = self.conferences[indexPath.row]
        let conferenceKey = conferenceName.lowercased().replacingOccurrences(of: " ", with: "")
        
        
        cell.addRefreshControl()
        cell.scheduleTableView.delegate = cell
        cell.scheduleTableView.dataSource = cell
        cell.scheduleTableView.allowsSelection = false
        cell.scheduleTableView.rowHeight = UITableViewAutomaticDimension
        cell.scheduleTableView.estimatedRowHeight = 50
        cell.scheduleTableView.layer.cornerRadius = 10
        cell.games = self.games[conferenceKey] ?? []
        cell.conferenceName = conferenceName
        cell.scheduleTableView.reloadData()
        
        return cell
    }
}


extension GamedayViewController : UICollectionViewDelegateFlowLayout {
    // responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
    
    //  returns the spacing between the cells, headers, and footers. A constant is used to store the value
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0;
    }
}