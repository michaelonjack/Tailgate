//
//  CreateTailgateInvitesViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/19/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase
import SwipeNavigationController

class InvitesViewController: UIViewController {
    
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var tailgate: Tailgate!
    var friends:[User] = []
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
        
        self.selectedInvites = tailgate.invites
        
        getUsers( completion: { (users) in
            self.friends = users
            self.usersTable.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donePressed(_ sender: Any) {
        updateTailgateInvites(tailgate: self.tailgate, invites: self.selectedInvites)
        
        // Update the tailgate values in the tailgate VC's variable
        if let presenter = presentingViewController as? SwipeNavigationController {
            if let tailgateVC = presenter.rightViewController as? TailgateViewController {
                tailgateVC.tailgate.invites = self.selectedInvites
            }
        }
        
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
        self.selectedInvites.append( friends[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Remove the friend from the invites list when deselected
        let uninvitedFriendId = friends[indexPath.row].uid
        
        self.selectedInvites = self.selectedInvites.filter{$0.uid != uninvitedFriendId}
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
        
        // Highlight the users that are already invited
        for invite in selectedInvites {
            if invite.uid == self.friends[indexPath.row].uid {
                self.usersTable.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            }
        }
        
        var matchesFound = 0
        for index in 0...self.friends.count-1 {
            let currUser = self.friends[index]
            
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
            
            for user in friends {
                if user.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                    count = count + 1
                }
            }
            
            return count
        }
            
        else {
            return self.friends.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

