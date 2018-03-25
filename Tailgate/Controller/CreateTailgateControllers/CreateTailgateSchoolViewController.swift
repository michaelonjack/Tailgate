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
    @IBOutlet weak var searchTextField: UITextField!
    
    var tailgateName: String!
    var schools: [School] = []
    var searchResults: [School] = []
    var selectedSchool: School!
    var searchText:String = "" {
        didSet {
            if searchText == "" {
                searchResults = schools
            } else {
                searchResults = []
                for school in schools {
                    if school.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                        searchResults.append(school)
                    }
                }
            }
            
            schoolTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        schoolTable.delegate = self
        schoolTable.dataSource = self
        searchTextField.delegate = self
        
        
        getSchools(completion: { (schools) in
            self.schools = schools
            self.searchResults = schools
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



extension CreateTailgateSchoolViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedValue = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        self.searchText = updatedValue
        return true
    }
    
}



extension CreateTailgateSchoolViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSchool = searchResults[indexPath.row]
    }
    
}



extension CreateTailgateSchoolViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolTableCell", for: indexPath) as! SchoolTableViewCell
        
        let currSchool = self.searchResults[indexPath.row]
        
        // Reset the recycled cell's label
        cell.schoolNameLabel.text = ""
        
        cell.schoolNameLabel.text = currSchool.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
