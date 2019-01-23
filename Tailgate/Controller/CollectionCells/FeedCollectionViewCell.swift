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
    var detailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.alpha = 0
        
        return label
    }()
    
    var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.effect = UIBlurEffect(style: UIBlurEffect.Style.light)
        view.alpha = 0
        
        return view
    }()
    
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
        addSubview(blurView)
        addSubview(detailsLabel)
        
        setupLayout()
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leftAnchor.constraint(equalTo: leftAnchor),
            blurView.rightAnchor.constraint(equalTo: rightAnchor),
            
            detailsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            detailsLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            detailsLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            detailsLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6)
        ])
    }
}
