//
//  FriendTableViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 2/21/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var isRemoveIcon: Bool = false
    var userId: String = ""
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        
        if self.isRemoveIcon {
            removeFriend(friendId: self.userId)
        } else {
            addFriend(friendId: self.userId)
        }
        
        UIView.animate(withDuration: 0.5) {
            if self.isRemoveIcon {
                self.actionButton.transform = self.actionButton.transform.rotated(by: (3.0 * CGFloat.pi) / 4.0)
            } else {
                self.actionButton.transform = self.actionButton.transform.rotated(by: -(3.0 * CGFloat.pi) / 4.0)
            }
            
            self.isRemoveIcon = !self.isRemoveIcon
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
