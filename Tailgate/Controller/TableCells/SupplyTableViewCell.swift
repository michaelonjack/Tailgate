//
//  SupplyTableViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 5/11/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class SupplyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var supplyNameLabel: UILabel!
    @IBOutlet weak var supplierLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
