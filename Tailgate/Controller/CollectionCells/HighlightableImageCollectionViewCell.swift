//
//  HighlightableImageCollectionViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 2/18/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class HighlightableImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var borderColor:UIColor = UIColor.init(red: 0, green: 0.98, blue: 0.57, alpha: 1.0)
    override var isSelected: Bool {
        didSet {
            self.contentView.layer.borderWidth = isSelected ? 1 : 0
            self.contentView.layer.borderColor = isSelected ? borderColor.cgColor : nil
        }
    }
}
