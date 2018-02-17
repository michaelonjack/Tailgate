//
//  CreateTailgateInvitesViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/19/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase

class CreateTailgateInvitesViewController: UIViewController {
    
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    var startTime: Date!
    var foods:[Food]!
    var drinks:[Drink]!
    
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
    
    @IBAction func createPressed(_ sender: Any) {
        
        let newTailgate = Tailgate(owner: (Auth.auth().currentUser?.uid)!, name: tailgateName, school: tailgateSchool, isPublic: isPublic, startTime: startTime, foods: foods, drinks: drinks, invites: selectedInvites)
        
        let tailgateReference = Database.database().reference(withPath: "tailgates/" + newTailgate.id)
        tailgateReference.setValue(newTailgate.toAnyObject())
        
        let userTailgateReference = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)! + "/tailgate")
        userTailgateReference.setValue(newTailgate.id)
        
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
        self.selectedInvites.append( invites[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Remove the friend from the invites list when deselected
        let uninvitedFriendId = invites[indexPath.row].uid
        
        self.selectedInvites = self.selectedInvites.filter{$0.uid != uninvitedFriendId}
    }
    
}



extension CreateTailgateInvitesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! UserTableViewCell
        
        // Reset the recycled cell's label
        cell.nameLabel.text = ""
        // Reset the recycled cell's profile picture
        cell.profilePicture.image = UIImage(named: "Avatar")
        
        var matchesFound = 0
        for index in 0...self.invites.count-1 {
            let currUser = self.invites[index]
            
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
