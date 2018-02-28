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
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            if self.isRemoveIcon {
                // Swift won't rotate +180 degree so first rotate 180 then an additional 45
                self.actionButton.transform = self.actionButton.transform.rotated(by: (3.0 * CGFloat.pi) / 4.0)
                //self.actionButton.transform = self.actionButton.transform.rotated(by: CGFloat.pi / 4.0)
            } else {
                // Swift won't rotate +180 degree so first rotate 180 then an additional 45
                self.actionButton.transform = self.actionButton.transform.rotated(by: -(3.0 * CGFloat.pi) / 4.0)
                //self.actionButton.transform = self.actionButton.transform.rotated(by: -CGFloat.pi)
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
