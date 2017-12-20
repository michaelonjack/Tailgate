//
//  CreateTailgateSchoolViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/16/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class CreateTailgateSchoolViewController: UIViewController {

    @IBOutlet weak var schoolTable: UITableView!
    
    var tailgateName: String!
    var schools: [School] = []
    var selectedSchool: School!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schoolTable.delegate = self
        schoolTable.dataSource = self
        
        getSchools(completion: { (schools) in
            self.schools = schools
            self.schoolTable.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        
        if let _ = schoolTable.indexPathForSelectedRow {
            self.performSegue(withIdentifier: "SchoolToAccessibility", sender: nil)
        }
        
        else {
            let errorAlert = UIAlertController(
                title: "",
                message: "School is required",
                preferredStyle: .alert
            )
            
            let closeAction = UIAlertAction(title: "Close", style: .default)
            errorAlert.addAction(closeAction)
            self.present(errorAlert, animated: true, completion:nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let accVC: CreateTailgateAccessibilityViewController = segue.destination as! CreateTailgateAccessibilityViewController
        accVC.tailgateName = self.tailgateName
        accVC.tailgateSchool = self.selectedSchool
    }

}



extension CreateTailgateSchoolViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSchool = schools[indexPath.row]
    }
    
}



extension CreateTailgateSchoolViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolTableCell", for: indexPath) as! SchoolTableViewCell
        
        cell.schoolNameLabel.text = self.schools[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.schools.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
