//
//  FeedCollectionViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/24/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityTypeIndicator: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailLabelTrailingConstraint: NSLayoutConstraint!
    
}
