//
//  ExploreCollectionViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 1/20/19.
//  Copyright © 2019 Michael Onjack. All rights reserved.
//

import UIKit

class ExploreCollectionViewCell: UICollectionViewCell {
    
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
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.667),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.667)
        ])
    }
}
