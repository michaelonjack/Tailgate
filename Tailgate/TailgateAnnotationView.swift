//
//  TailgateAnnotationView.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/9/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import Foundation
import MapKit

class TailgateAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let tailgate = newValue as? Tailgate else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            
            // Here, you create a UIButton, set its background image to the Maps icon, then set the view’s right callout accessory to this button
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "MapsIcon"), for: UIControlState())
            rightCalloutAccessoryView = mapsButton
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = tailgate.owner
            detailCalloutAccessoryView = detailLabel
            
            image = UIImage(named: tailgate.school)
        }
    }
}
