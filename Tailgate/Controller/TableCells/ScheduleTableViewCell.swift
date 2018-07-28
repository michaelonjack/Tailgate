//
//  ScheduleTableViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var teamsLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var awayTeamLogo: UIImageView!
    @IBOutlet weak var homeTeamLogo: UIImageView!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamLogoLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var homeTeamLogoTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
