//
//  GamedayScheduleViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class GamedayScheduleViewController: UIViewController {

    @IBOutlet weak var schedulesCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLableTopConstraint: NSLayoutConstraint!
    
    var conferences = ["BIG 10", "BIG 12", "ACC", "PAC-12", "SEC"]
    var games:[String:[GameCell]] = [:]
    var selectedWeek: Int?
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
            
            getCurrentGameCellsForConference(conferenceName: conferenceKey, completion: { (games) in
                self.games[conferenceKey] = games
                self.schedulesCollectionView.reloadItems(at: [IndexPath(item: self.games.count-1, section: 0)])
            })
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ScheduleToPickerPopup" {
            
            guard let popupController = segue.destination as? PickerPopupViewController else {return}
            
            var values:[String] = []
            for i in 1..<14 {
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



extension GamedayScheduleViewController: PickerPopupDelegate {
    func selectPressed(popupController: PickerPopupViewController, selectedIndex:Int, selectedValue: String) {
        
        DispatchQueue.main.async {
            popupController.dismiss(animated: true, completion: nil)
            self.weekButton.setTitle(selectedValue, for: .normal)
        }
        
        selectedWeek = selectedIndex + 1
        
        games = [:]
        
        // Get games for selected week
        for conference in conferences {
            let conferenceKey = conference.lowercased().replacingOccurrences(of: " ", with: "")
            
            getCurrentGameCellsForConference(conferenceName: conferenceKey, forWeek: selectedWeek!, completion: { (games) in
                self.games[conferenceKey] = games
                self.schedulesCollectionView.reloadItems(at: [IndexPath(item: self.games.count-1, section: 0)])
                
                if self.games.count == self.conferences.count {
                    DispatchQueue.main.async {
                        print("reloading")
                        self.schedulesCollectionView.reloadData()
                    }
                }
            })
        }
    }
    
    
}



extension GamedayScheduleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}



extension GamedayScheduleViewController: UICollectionViewDataSource {
    // There’s one search per section, so the number of sections is the count of the searches array
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.conferences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCollectionViewCell
        
        let conferenceName = self.conferences[indexPath.row]
        let conferenceKey = conferenceName.lowercased().replacingOccurrences(of: " ", with: "")
        
        cell.addRefreshControl()
        cell.scheduleTableView.delegate = cell
        cell.scheduleTableView.dataSource = cell
        cell.scheduleTableView.allowsSelection = true
        cell.scheduleTableView.rowHeight = UITableViewAutomaticDimension
        cell.scheduleTableView.estimatedRowHeight = 44
        cell.scheduleTableView.layer.cornerRadius = 10
        cell.games = self.games[conferenceKey] ?? []
        cell.conferenceName = conferenceName
        cell.scheduleTableView.reloadData()
        
        return cell
    }
}


extension GamedayScheduleViewController : UICollectionViewDelegateFlowLayout {
    // responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate the cell height because collectionView.bounds.size.height isn't reliable when the view first loads
        var collectionViewHeight = UIScreen.main.bounds.size.height - UIApplication.shared.statusBarFrame.height - self.titleLableTopConstraint.constant - self.titleLabel.bounds.height - self.navigationView.bounds.height - self.collectionViewTopConstraint.constant
        
        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindow {
                let safeAreaBottom = window.safeAreaInsets.bottom
                collectionViewHeight = collectionViewHeight - safeAreaBottom
            }
        }
        
        return CGSize(width: collectionView.bounds.size.width, height: collectionViewHeight)
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
