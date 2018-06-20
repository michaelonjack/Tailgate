//
//  CreateTailgateInvitesViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/19/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateTailgateInvitesViewController: UIViewController {
    
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet var emptyView: UIView!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    var startTime: Date!
    var supplies:[Supply]!
    var flairUrl:String!
    
    var friends:[User] = []
    var searchResults:[User] = []
    var selectedFriends:[User] = []
    var state = TableState.loading {
        didSet {
            setTableBackgroundView()
        }
    }
    var searchText:String = "" {
        didSet {
            if searchText == "" {
                searchResults = friends
            } else {
                searchResults = []
                for friend in friends {
                    if friend.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                        searchResults.append(friend)
                    }
                }
            }
            
            usersTable.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        usersTable.delegate = self
        usersTable.dataSource = self
        usersTable.allowsMultipleSelection = true
        usersTable.rowHeight = UITableViewAutomaticDimension
        usersTable.estimatedRowHeight = 100
        
        searchTextField.delegate = self

        getFriends( completion: { (users) in
            self.friends = users
            self.searchResults = users
            self.usersTable.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func setTableBackgroundView() {
        switch state {
        case .empty, .loading:
            usersTable.backgroundView = emptyView
            usersTable.backgroundView?.isHidden = false
            usersTable.separatorStyle = .none
        default:
            usersTable.backgroundView?.isHidden = true
            usersTable.backgroundView = nil
            usersTable.separatorStyle = .singleLine
        }
    }
    
    
    
    @IBAction func createPressed(_ sender: Any) {
        
        let newTailgate = Tailgate(ownerId: (Auth.auth().currentUser?.uid)!, name: tailgateName, school: tailgateSchool, flairImageUrl: flairUrl, isPublic: isPublic, startTime: startTime, supplies: supplies, invites: selectedFriends)
        
        let tailgateReference = Database.database().reference(withPath: "tailgates/" + newTailgate.id)
        tailgateReference.setValue(newTailgate.toAnyObject())
        
        let userTailgateReference = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)! + "/tailgate")
        userTailgateReference.setValue(newTailgate.id)
        
        // Add the tailgate to each invited firends invites list
        for friend in selectedFriends {
            let friendReference = Database.database().reference(withPath: "users/" + friend.uid)
            friendReference.child("invites").updateChildValues([newTailgate.id:true])
        }
        
        // Create a new controller to hold the new tailgate data
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tailgateViewController = mainStoryboard.instantiateViewController(withIdentifier: "TailgateViewController") as! TailgateViewController
        tailgateViewController.tailgate = newTailgate
        
        self.containerSwipeNavigationController?.showEmbeddedView(position: .center)
        self.containerSwipeNavigationController?.rightViewController = tailgateViewController
    }
    
}





extension CreateTailgateInvitesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedValue = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        self.searchText = updatedValue
        return true
    }
    
}



extension CreateTailgateInvitesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedFriends.append( searchResults[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Remove the friend from the friends list when deselected
        let uninvitedFriendId = searchResults[indexPath.row].uid
        
        self.selectedFriends = self.selectedFriends.filter{$0.uid != uninvitedFriendId}
    }
    
}



extension CreateTailgateInvitesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! UserTableViewCell
        
        // Reset the recycled cell's label
        cell.nameLabel.text = ""
        // Reset the recycled cell's profile picture
        cell.profilePicture.image = UIImage(named: "Avatar")
        
        let currUser = self.searchResults[indexPath.row]
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
            state = .populated
        } else {
            state = .empty
        }
        
        return self.searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
