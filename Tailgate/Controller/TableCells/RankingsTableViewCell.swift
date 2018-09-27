//
//  RankingsTableViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 9/24/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class RankingsTableViewCell: UITableViewCell {

    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var schoolLogo: UIImageView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var rankLabelLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
