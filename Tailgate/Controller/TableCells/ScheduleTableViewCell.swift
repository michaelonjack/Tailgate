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
    @IBOutlet weak var gameLink: UIButton!
    @IBOutlet weak var awayTeamLogo: UIImageView!
    @IBOutlet weak var homeTeamLogo: UIImageView!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamLogoLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var homeTeamLogoTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gameLink.titleLabel?.adjustsFontSizeToFitWidth = true
        gameLink.titleLabel?.minimumScaleFactor = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func gameLinkPressed(_ sender: Any) {
        if let teamsStr = self.teamsLabel.text {
            let gameLink = "https://www.google.com/search?q=" + teamsStr.replacingOccurrences(of: " ", with: "%20") + "%20football"
            guard let gameUrl = URL(string: gameLink) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(gameUrl) {
                UIApplication.shared.open(gameUrl, options: [:])
            }
        }
    }
}
