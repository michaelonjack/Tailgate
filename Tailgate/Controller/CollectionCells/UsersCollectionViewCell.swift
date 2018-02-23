//
//  UsersCollectionViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 2/21/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class UsersCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userTableView: UITableView!
    
    var users:[User] = []
}



extension UsersCollectionViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}



extension UsersCollectionViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableCell", for: indexPath) as! FriendTableViewCell
        
        // Reset the recycled cell's label
        cell.nameLabel.text = ""
        // Reset the recycled cell's profile picture
        cell.profilePicture.image = UIImage(named: "Avatar")
        // Reset the cell's selection
        cell.setSelected(false, animated: false)
        
        let currUser = self.users[indexPath.row]
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
        return self.users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
