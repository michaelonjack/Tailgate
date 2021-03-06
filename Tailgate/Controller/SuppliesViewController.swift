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
    @IBOutlet var emptyView: UIView!
    
    var tailgate: Tailgate!
    var supplies:[Supply] = []
    var newSupplyText:String = ""
    var state = TableState.loading {
        didSet {
            setTableBackgroundView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        supplies = tailgate.supplies

        suppliesTable.delegate = self
        suppliesTable.dataSource = self
        
        newSupplyTextField.delegate = self
        
        if !tailgate.isUserInvited(userId: getCurrentUserId()) && !tailgate.isOwner(userId: getCurrentUserId()) {
            self.addSupplyButton.isHidden = true
            self.newSupplyTextField.isHidden = true
            self.titleLabel.text = "Supplies"
        }
    }
    
    
    
    @IBAction func addSupplyPressed(_ sender: Any) {
        
        if let supplyName = self.newSupplyTextField.text, supplyName.replacingOccurrences(of: " ", with: "") != "" {
            getCurrentUser { (currentUser) in
                let supplier = currentUser.name
                
                let newSupply = Supply(name: supplyName, supplier: supplier)
                
                DispatchQueue.main.async {
                    self.newSupplyText = ""
                    self.newSupplyTextField.text = ""
                    
                    self.suppliesTable.beginUpdates()
                    self.supplies.append(newSupply)
                    self.suppliesTable.insertRows(at: [IndexPath(row: self.supplies.count-1, section: 0)], with: .none)
                    self.suppliesTable.endUpdates()
                }
            }
        }
        
        else {
            let alert = createAlert(title: "", message: "Give your supply a name!")
            
            self.present(alert, animated: true)
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
    }
    
    
    
    func setTableBackgroundView() {
        switch state {
        case .empty, .loading:
            suppliesTable.backgroundView = emptyView
            suppliesTable.backgroundView?.isHidden = false
            suppliesTable.separatorStyle = .none
        default:
            suppliesTable.backgroundView?.isHidden = true
            suppliesTable.backgroundView = nil
            suppliesTable.separatorStyle = .singleLine
        }
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tailgate.isOwner(userId: configuration.currentUser.uid) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            supplies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
            tableView.endUpdates()
        }
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
            self.state = .populated
        } else {
            self.state = .empty
        }
        
        return self.supplies.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
