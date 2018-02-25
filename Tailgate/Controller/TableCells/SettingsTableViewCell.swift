//
//  SettingsTableViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 2/24/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var rowNameLabel: UILabel!
    @IBOutlet weak var rowValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
