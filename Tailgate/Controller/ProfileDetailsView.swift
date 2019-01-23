//
//  ProfileDetailsView.swift
//  Tailgate
//
//  Created by Michael Onjack on 1/20/19.
//  Copyright © 2019 Michael Onjack. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileDetailsView: UIView {
    
    var basicDetailsView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var feedView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var exploreView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        
        return view
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont(name: "Avenir-Heavy", size: 18)
        label.textAlignment = .left
        
        return label
    }()
    
    var schoolLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont(name: "Avenir-Light", size: 14)
        label.textAlignment = .left
        
        return label
    }()
    
    var schoolIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "HomeTeamDefault")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    var feedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tailgates"
        label.font = UIFont(name: "Avenir-Heavy", size: 20)
        label.textAlignment = .left
        
        return label
    }()
    
    var exploreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Explore"
        label.font = UIFont(name: "Avenir-Heavy", size: 20)
        label.textAlignment = .left
        
        return label
    }()
    
    var feedCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 20
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: "feedCell")
        
        return collectionView
    }()
    
    var exploreCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 20
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ExploreCollectionViewCell.self, forCellWithReuseIdentifier: "exploreCell")
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 40
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 40
        
        setupView()
    }
    
    func setupView() {
        
        addSubview(basicDetailsView)
        addSubview(feedView)
        addSubview(exploreView)
        
        basicDetailsView.addSubview(nameLabel)
        basicDetailsView.addSubview(schoolLabel)
        basicDetailsView.addSubview(schoolIcon)
        
        feedView.addSubview(feedLabel)
        feedView.addSubview(feedCollectionView)
        feedView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleFeedViewLongPress)))
        
        exploreView.addSubview(exploreLabel)
        exploreView.addSubview(exploreCollectionView)
        
        setupLayout()
        
        getCurrentUser { (currentUser) in
            DispatchQueue.main.async {
                self.nameLabel.text = currentUser.name
                self.schoolLabel.text = currentUser.schoolName
                
                if let schoolName = currentUser.schoolName {
                    getSchoolByName(name: schoolName, completion: { (school) in
                        if let schoolLogoUrlStr = school.logoUrl {
                            let schoolLogoUrl = URL(string: schoolLogoUrlStr)
                            self.schoolIcon.sd_setImage(with: schoolLogoUrl, completed: nil)
                        }
                    })
                }
            }
        }
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            basicDetailsView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            basicDetailsView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.07),
            basicDetailsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            basicDetailsView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            
            feedView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            feedView.centerXAnchor.constraint(equalTo: centerXAnchor),
            feedView.topAnchor.constraint(equalTo: basicDetailsView.bottomAnchor, constant: 20),
            feedView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
            
            exploreView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            exploreView.centerXAnchor.constraint(equalTo: centerXAnchor),
            exploreView.topAnchor.constraint(equalTo: feedView.bottomAnchor, constant: 20),
            exploreView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
            
            nameLabel.topAnchor.constraint(equalTo: basicDetailsView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: basicDetailsView.leadingAnchor),
            nameLabel.widthAnchor.constraint(equalTo: basicDetailsView.widthAnchor, multiplier: 0.8),
            nameLabel.heightAnchor.constraint(equalTo: basicDetailsView.heightAnchor, multiplier: 0.5),
            
            schoolLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            schoolLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            schoolLabel.bottomAnchor.constraint(equalTo: basicDetailsView.bottomAnchor),
            schoolLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor),
            
            schoolIcon.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            schoolIcon.trailingAnchor.constraint(equalTo: basicDetailsView.trailingAnchor),
            schoolIcon.topAnchor.constraint(equalTo: basicDetailsView.topAnchor),
            schoolIcon.bottomAnchor.constraint(equalTo: basicDetailsView.bottomAnchor),
            
            feedLabel.topAnchor.constraint(equalTo: feedView.topAnchor),
            feedLabel.leadingAnchor.constraint(equalTo: feedView.leadingAnchor),
            feedLabel.trailingAnchor.constraint(equalTo: feedView.trailingAnchor),
            feedLabel.heightAnchor.constraint(equalTo: feedView.heightAnchor, multiplier: 0.2),
            
            feedCollectionView.topAnchor.constraint(equalTo: feedLabel.bottomAnchor),
            feedCollectionView.leadingAnchor.constraint(equalTo: feedView.leadingAnchor),
            feedCollectionView.trailingAnchor.constraint(equalTo: feedView.trailingAnchor),
            feedCollectionView.bottomAnchor.constraint(equalTo: feedView.bottomAnchor),
            
            exploreLabel.topAnchor.constraint(equalTo: exploreView.topAnchor),
            exploreLabel.leadingAnchor.constraint(equalTo: exploreView.leadingAnchor),
            exploreLabel.trailingAnchor.constraint(equalTo: exploreView.trailingAnchor),
            exploreLabel.heightAnchor.constraint(equalTo: exploreView.heightAnchor, multiplier: 0.2),
            
            exploreCollectionView.topAnchor.constraint(equalTo: exploreLabel.bottomAnchor),
            exploreCollectionView.leadingAnchor.constraint(equalTo: exploreView.leadingAnchor),
            exploreCollectionView.trailingAnchor.constraint(equalTo: exploreView.trailingAnchor),
            exploreCollectionView.bottomAnchor.constraint(equalTo: exploreView.bottomAnchor)
        ])
    }
    
    func reloadBasicDetailsView() {
        DispatchQueue.main.async {
            self.nameLabel.text = configuration.currentUser.name
            self.schoolLabel.text = configuration.currentUser.schoolName
            
            if let schoolName = configuration.currentUser.schoolName {
                getSchoolByName(name: schoolName, completion: { (school) in
                    if let schoolLogoUrlStr = school.logoUrl {
                        let schoolLogoUrl = URL(string: schoolLogoUrlStr)
                        self.schoolIcon.sd_setImage(with: schoolLogoUrl, completed: nil)
                    }
                })
            }
        }
    }
    
    @objc func handleFeedViewLongPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            
            feedCollectionView.visibleCells.filter { (cell) -> Bool in
                guard let cell = cell as? FeedCollectionViewCell else { return false }
                return cell.blurView.alpha == 1
            }.forEach { (cell) in
                // Once the long press completes, hide the details label and un-blur
                guard let cell = cell as? FeedCollectionViewCell else { return }
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                    cell.detailsLabel.alpha = 0
                    cell.blurView.alpha = 0
                })
            }
        } else if gesture.state == .began {
            let pressLocation = gesture.location(in: feedCollectionView)
            guard let indexPath = feedCollectionView.indexPathForItem(at: pressLocation) else { return }
            guard let cell = feedCollectionView.cellForItem(at: indexPath) as? FeedCollectionViewCell else { return }
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                cell.detailsLabel.alpha = 1
                cell.blurView.alpha = 1
            })
        }
    }
}
