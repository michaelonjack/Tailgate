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
    var searchResults:[User] = []
    var selectedInvites:[User] = []
    var isOwner:Bool!
    var searchText:String = "" {
        didSet {
            if searchText == "" {
                if self.isOwner == true {
                    searchResults = friends
                } else {
                    searchResults = self.tailgate.invites
                }
            } else {
                searchResults = []
                if self.isOwner == true {
                    for friend in friends {
                        if friend.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                            searchResults.append(friend)
                        }
                    }
                } else {
                    for invite in self.tailgate.invites {
                        if invite.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                            searchResults.append(invite)
                        }
                    }
                }
            }
            
            usersTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isOwner = self.tailgate.ownerId == Auth.auth().currentUser?.uid
        
        usersTable.delegate = self
        usersTable.dataSource = self
        usersTable.allowsSelection = isOwner == true
        usersTable.allowsMultipleSelection = isOwner == true
        usersTable.rowHeight = UITableViewAutomaticDimension
        usersTable.estimatedRowHeight = 100
        usersTable.backgroundView = EmptyBackgroundView(scrollView: self.usersTable, image: UIImage(named: "Search2")!, title: "No Results Found", message: "Try entering a new search term.")
        
        searchTextField.delegate = self
        
        self.selectedInvites = tailgate.invites
        
        getFriends( completion: { (users) in
            self.friends = users
            if self.isOwner == true {
                self.searchResults = users
            } else {
                self.searchResults = self.tailgate.invites
            }
            self.usersTable.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donePressed(_ sender: Any) {
        updateTailgateInvites(tailgate: self.tailgate, invites: self.selectedInvites)
        
        // Add the tailgate to each invited firends invites list
        for invite in self.selectedInvites {
            let inviteReference = Database.database().reference(withPath: "users/" + invite.uid)
            inviteReference.child("invites").updateChildValues([self.tailgate.id:true])
        }
        
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
        // Only allow the owner to add invites
        if self.isOwner == true {
            self.selectedInvites.append( searchResults[indexPath.row] )
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Remove the friend from the invites list when deselected
        if self.isOwner == true {
            let uninvitedFriendId = searchResults[indexPath.row].uid
            
            self.selectedInvites = self.selectedInvites.filter{$0.uid != uninvitedFriendId}
        }
    }
    
}



extension InvitesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! UserTableViewCell
        
        let currUser = self.searchResults[indexPath.row]
        
        // Reset the recycled cell's label
        cell.nameLabel.text = ""
        // Reset the recycled cell's profile picture
        cell.profilePicture.image = UIImage(named: "Avatar")
        // Reset the cell's selection
        cell.setSelected(false, animated: false)
        
        // Highlight the users that are already invited
        for invite in selectedInvites {
            if invite.uid == self.searchResults[indexPath.row].uid {
                self.usersTable.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            }
        }
        
        cell.nameLabel.text = currUser.name
        
        if let profilePicUrl = currUser.profilePictureUrl {
            if profilePicUrl != "" {
                let pictureUrl = URL(string: profilePicUrl)
                cell.profilePicture.sd_setImage(with: pictureUrl, completed: nil)
                cell.profilePicture.layer.cornerRadius = 0.5 * cell.profilePicture.layer.bounds.width
                cell.profilePicture.clipsToBounds = true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchResults.count > 0 {
            usersTable.backgroundView?.isHidden = true
            usersTable.separatorStyle = .singleLine
        } else {
            usersTable.backgroundView?.isHidden = false
            usersTable.separatorStyle = .none
        }
        
        return self.searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.isOwner == true
    }
}

