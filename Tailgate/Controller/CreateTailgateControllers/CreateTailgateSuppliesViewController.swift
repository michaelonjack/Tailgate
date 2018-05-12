//
//  CreateTailgateFoodViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/16/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class CreateTailgateSuppliesViewController: UIViewController {
    
    @IBOutlet weak var suppliesTable: UITableView!
    @IBOutlet weak var newSupplyTextField: UITextField!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    var startTime: Date!
    
    var supplies:[Supply] = []
    var newSupplyText:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        suppliesTable.delegate = self
        suppliesTable.dataSource = self
        suppliesTable.backgroundView = EmptyBackgroundView(scrollView: self.suppliesTable, image: UIImage(named: "Food2")!, title: "No Food :(", message: "Tailgate with no food...hard pass..")
        
        newSupplyTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addSupplyPressed(_ sender: Any) {
        
        if let supplyName = self.newSupplyTextField.text {
            getCurrentUser { (currentUser) in
                let supplier = currentUser.name
                
                let newSupply = Supply(name: supplyName, supplier: supplier)
                self.supplies.append(newSupply)
                
                DispatchQueue.main.async {
                    self.newSupplyText = ""
                    self.newSupplyTextField.text = ""
                    self.suppliesTable.reloadData()
                }
            }
        }
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "SuppliesToFlair", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let flairVC: CreateTailgateFlairViewController = segue.destination as! CreateTailgateFlairViewController
        flairVC.tailgateName = self.tailgateName
        flairVC.tailgateSchool = self.tailgateSchool
        flairVC.isPublic = self.isPublic
        flairVC.startTime = self.startTime
        flairVC.supplies = self.supplies
    }
}



extension CreateTailgateSuppliesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedValue = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        self.newSupplyText = updatedValue
        return true
    }
    
}




extension CreateTailgateSuppliesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}



extension CreateTailgateSuppliesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplyTableCell", for: indexPath) as! SupplyTableViewCell
        
        let currSupply:Supply = self.supplies[indexPath.row]
        
        // Reset the recycled cell's label
        cell.supplyNameLabel.text = ""
        cell.supplierLabel.text = ""
        
        cell.supplyNameLabel.text = currSupply.name
        cell.supplierLabel.text = currSupply.supplier
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.supplies.count > 0 {
            suppliesTable.backgroundView?.isHidden = true
            suppliesTable.separatorStyle = .singleLine
        } else {
            suppliesTable.backgroundView?.isHidden = false
            suppliesTable.separatorStyle = .none
        }
        
        return self.supplies.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
