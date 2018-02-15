//
//  TailgateAnnotation.swift
//  Tailgate annotation used on the standard map
//
//  Created by Michael Onjack on 12/9/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import SDWebImage

class TailgateAnnotation: NSObject, MKAnnotation {
    let location: CLLocation
    let coordinate: CLLocationCoordinate2D
    let id: String 
    let title: String?
    let school: String
    var owner: String
    var annotationImageView: UIImageView?
    var tailgate: Tailgate?

    init(tailgate: Tailgate) {
        self.id = tailgate.id
        self.title = tailgate.name
        self.school = tailgate.school.name
        self.location = tailgate.location!
        self.coordinate = location.coordinate
        self.annotationImageView = nil
        self.owner = ""
        self.tailgate = tailgate
        
        super.init()
        
        getUserById(userId: tailgate.owner, completion: { (user) in
            self.owner = user.name
        })
        
    }
    
    init(id:String, title:String, school: String, owner: String, location: CLLocation) {
        self.id = id
        self.title = title
        self.school = school
        self.owner = owner
        self.location = location
        self.coordinate = location.coordinate
        
        super.init()
    }
}
