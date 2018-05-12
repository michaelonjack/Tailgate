//
//  SuppliesViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 5/11/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import SwipeNavigationController

class SuppliesViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var suppliesTable: UITableView!
    @IBOutlet weak var newSupplyTextField: UITextField!
    @IBOutlet weak var addSupplyButton: UIButton!
    
    var tailgate: Tailgate!
    var supplies:[Supply] = []
    var newSupplyText:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        supplies = tailgate.supplies

        suppliesTable.delegate = self
        suppliesTable.dataSource = self
        suppliesTable.backgroundView = EmptyBackgroundView(scrollView: self.suppliesTable, image: UIImage(named: "Food2")!, title: "No Food :(", message: "Tailgate with no food...hard pass..")
        
        newSupplyTextField.delegate = self
        
        if !tailgate.isUserInvited(userId: getCurrentUserId()) && !tailgate.isOwner(userId: getCurrentUserId()) {
            self.addSupplyButton.isHidden = true
            self.newSupplyTextField.isHidden = true
            self.titleLabel.text = "Supplies"
        }
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
    
    
    
    @IBAction func donePressed(_ sender: Any) {
        updateTailgateSupplies(tailgate: self.tailgate, supplies: self.supplies)
        
        // Update the tailgate values in the tailgate VC's variable
        if let presenter = presentingViewController as? SwipeNavigationController {
            if let tailgateVC = presenter.rightViewController as? TailgateViewController {
                tailgateVC.tailgate.supplies = self.supplies
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



extension SuppliesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedValue = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        self.newSupplyText = updatedValue
        return true
    }
    
}



extension SuppliesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}



extension SuppliesViewController: UITableViewDataSource {
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
