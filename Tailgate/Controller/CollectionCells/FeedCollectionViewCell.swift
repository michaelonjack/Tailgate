//
//  FeedCollectionViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/24/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var activityTypeIndicator: UIView!
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var detailLabel: UILabel!
//    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var indicatorTrailingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var detailLabelTrailingConstraint: NSLayoutConstraint!
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    func setupView() {
        
        imageView = UIImageView(frame: CGRect.zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        setupLayout()
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
