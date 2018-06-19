//
//  TailgateAnnotationView.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/9/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import Foundation
import MapKit
import FirebaseDatabase
import SDWebImage

class TailgateAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let tailgate = newValue as? TailgateAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            
            // Here, you create a UIButton, set its background image to the Maps icon, then set the view’s right callout accessory to this button
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "MapsIcon"), for: UIControlState())
            rightCalloutAccessoryView = mapsButton
            
            // Here, you create a UIButton, set its background image to the Maps icon, then set the view’s right callout accessory to this button
            let infoButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 30, height: 30)))
            infoButton.setBackgroundImage(UIImage(named: "Open"), for: UIControlState())
            leftCalloutAccessoryView = infoButton
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = tailgate.owner
            detailCalloutAccessoryView = detailLabel
            
            let schoolPath = tailgate.school.replacingOccurrences(of: " ", with: "")
            let schoolReference = Database.database().reference(withPath: "schools/" + schoolPath)
            schoolReference.observeSingleEvent(of: .value, with: { (snapshot) in
                let dataDict = snapshot.value as? NSDictionary
                
                if snapshot.hasChild("annotationImageUrl") {
                    let flairUrlStr = tailgate.flairImageUrl
                    let picUrlStr = dataDict?["annotationImageUrl"] as? String ?? ""
                    
                    if flairUrlStr != "" {
                        let picUrl = URL(string: flairUrlStr)
                        self.sd_setImage(with: picUrl, completed: nil)
                    }
                    
                    else if picUrlStr != "" {
                        let picUrl = URL(string: picUrlStr)
                        self.sd_setImage(with: picUrl, completed: nil)
                    }
                }
            })
            
            image = tailgate.annotationImageView?.image
        }
    }
}
