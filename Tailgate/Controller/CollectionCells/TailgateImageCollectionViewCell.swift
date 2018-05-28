//
//  TailgateImageCollectionViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 5/28/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

protocol TailgateImageCellDelegate: class {
    func delete(cell: TailgateImageCollectionViewCell)
}

class TailgateImageCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: TailgateImageCellDelegate?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.delete(cell: self)
    }
}
