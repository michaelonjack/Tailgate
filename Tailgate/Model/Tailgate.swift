//
//  Tailgate.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/9/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import Foundation
import MapKit

class Tailgate: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let school: String
    let owner: String

    
    init(title:String, school: String, owner: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.school = school
        self.owner = owner
        self.coordinate = coordinate
        
        super.init()
    }
}
