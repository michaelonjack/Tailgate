//
//  FlairPhotoCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 2/18/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class FlairPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    override var isSelected: Bool {
        didSet {
            self.contentView.layer.borderWidth = isSelected ? 1 : 0
            self.contentView.layer.borderColor = isSelected ? UIColor.init(red: 0, green: 0.98, blue: 0.57, alpha: 1.0).cgColor : nil
        }
    }
}
