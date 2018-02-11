//
//  CreateTailgateInvitesViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/19/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase

class InvitesViewController: UIViewController {
    
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var invites:[User] = []
    var selectedInvites:[User] = []
    var searchText:String = "" {
        didSet {
            usersTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersTable.delegate = self
        usersTable.dataSource = self
        usersTable.allowsMultipleSelection = true
        usersTable.rowHeight = UITableViewAutomaticDimension
        usersTable.estimatedRowHeight = 100
        
        searchTextField.delegate = self
        
        getUsers( completion: { (users) in
            self.invites = users
            self.usersTable.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}





extension InvitesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedValue = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        self.searchText = updatedValue
        return true
    }
    
}



extension InvitesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedInvites.append( invites[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}



extension InvitesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! UserTableViewCell
        
        // Reset the recycled cell's label
        cell.nameLabel.text = ""
        // Reset the recycled cell's profile picture
        cell.profilePicture.image = UIImage(named: "Avatar")
        // Reset the cell's selection
        cell.setSelected(false, animated: false)
        
        for invite in selectedInvites {
            print(invite.email)
            print(self.invites[indexPath.row].email)
            if invite.uid == self.invites[indexPath.row].uid {
                self.usersTable.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            }
        }
        
        var matchesFound = 0
        for index in 0...self.invites.count-1 {
            let currUser = self.invites[index]
            
            // Add the user to the table if there is no search text or if the search text matches their name
            if self.searchText == "" || currUser.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                // We want to skip over matches that were already added to the table
                if matchesFound == indexPath.row {
                    cell.nameLabel.text = currUser.name
                    
                    if let profilePicUrl = currUser.profilePictureUrl {
                        if profilePicUrl != "" {
                            let pictureUrl = URL(string: profilePicUrl)
                            cell.profilePicture.sd_setImage(with: pictureUrl, completed: nil)
                            cell.profilePicture.layer.cornerRadius = 0.5 * cell.profilePicture.layer.bounds.width
                            cell.profilePicture.clipsToBounds = true
                        }
                    }
                    break
                }
                matchesFound = matchesFound + 1
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchText != "" {
            var count = 0
            
            for user in invites {
                if user.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                    count = count + 1
                }
            }
            
            return count
        }
            
        else {
            return self.invites.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

