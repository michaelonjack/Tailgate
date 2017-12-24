//
//  TailgateAnnotationAR.swift
//  Tailgate annotation used on the AR view with the camera
//
//  Created by Michael Onjack on 12/9/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import Foundation
import CoreLocation
import HDAugmentedReality

class TailgateAnnotationAR: ARAnnotation {
    let name: String
    let school: String
    let owner: String
    
    override var description: String {
        return name
    }
    
    init?(location: CLLocation, name: String, school: String, owner: String) {
        self.name = name
        self.school = school
        self.owner = owner
        
        super.init(identifier: name, title: name, location: location)
    }
}

