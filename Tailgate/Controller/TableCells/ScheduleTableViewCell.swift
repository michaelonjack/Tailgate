//
//  ScheduleTableViewCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var awayTeamLogo: UIImageView!
    @IBOutlet weak var awayTeamView: SlantedView!
    @IBOutlet weak var homeTeamLogo: UIImageView!
    @IBOutlet weak var homeTeamView: SlantedView!
    
    var diagonalLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        
        return view
    }()
    
    var blurDetailView: UIVisualEffectView = {
        let view = UIVisualEffectView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        view.alpha = 0
        
        return view
    }()
    
    var teamsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }()
    
    var detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }()
    
    var gameLink: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.lightGray, for: .normal)
        
        return button
    }()
    
    var detailStackView: UIStackView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        diagonalLine.transform = CGAffineTransform(rotationAngle: atan((frame.size.width * 0.5) / (frame.size.height * 0.5)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    func setupView() {
        detailStackView = UIStackView(arrangedSubviews: [teamsLabel, detailLabel, gameLink])
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.alpha = 0
        detailStackView.alignment = UIStackView.Alignment.center
        detailStackView.axis = .vertical
        detailStackView.distribution = .fillEqually
        
        addSubview(diagonalLine)
        addSubview(blurDetailView)
        addSubview(detailStackView)
        
        setupLayout()
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            blurDetailView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurDetailView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurDetailView.topAnchor.constraint(equalTo: topAnchor),
            blurDetailView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            detailStackView.centerXAnchor.constraint(equalTo: blurDetailView.centerXAnchor),
            detailStackView.centerYAnchor.constraint(equalTo: blurDetailView.centerYAnchor),
            detailStackView.heightAnchor.constraint(equalTo: blurDetailView.heightAnchor, multiplier: 0.8),
            detailStackView.widthAnchor.constraint(equalTo: blurDetailView.widthAnchor, multiplier: 0.7),
            
            diagonalLine.centerXAnchor.constraint(equalTo: centerXAnchor),
            diagonalLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            diagonalLine.widthAnchor.constraint(equalToConstant: 5),
            diagonalLine.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
}
