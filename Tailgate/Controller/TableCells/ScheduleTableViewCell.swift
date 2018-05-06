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
    
    var isExpanded:Bool = false
    var expandedHeight:CGFloat {
        return 11 + max(teamsLabel.bounds.size.height, detailLabel.bounds.size.height) + 12.5 + awayTeamLogo.bounds.size.height + 14.5 + max(awayTeamLabel.bounds.size.height, homeTeamLabel.bounds.size.height) + 12.5
    }
    var minimizedHeight:CGFloat {
        return (11*2) + max(teamsLabel.bounds.size.height, detailLabel.bounds.size.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
