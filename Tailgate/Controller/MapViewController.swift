//
//  MapViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/9/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager = CLLocationManager()
    var tailgates: [Tailgate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        
        // register the custom tailgate view with the map view’s default reuse identifier
        mapView.register(TailgateAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



extension MapViewController: MKMapViewDelegate {
    // When the user taps a map annotation marker, the callout shows an info button.
    // If the user taps this info button, this method is called
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        // you grab the Artwork object that this tap refers to
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}



extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Check if we've successfully received a location
        if let location:CLLocation = manager.location {
            
            // If you have a value of 50, it means that the real location can be in a circle with a radius of 50 meters around the position stored in location
            // We require the location to be within 100 meters of the actual location
            if location.horizontalAccuracy < 100 {
                manager.stopUpdatingLocation()
                
                // Zoom the map view to the current location
                let span = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta:0.004)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.region = region
                
                let loc1 = CLLocation(latitude: location.coordinate.latitude.advanced(by: 0.002), longitude: location.coordinate.longitude.advanced(by: 0.001))
                let loc2 = CLLocation(latitude: location.coordinate.latitude.advanced(by: 0.002), longitude: location.coordinate.longitude.advanced(by: -0.0001))
                let loc3 = CLLocation(latitude: location.coordinate.latitude.advanced(by: 0.0001), longitude: location.coordinate.longitude.advanced(by: 0.0002))
                let loc4 = CLLocation(latitude: location.coordinate.latitude.advanced(by: -0.0001), longitude: location.coordinate.longitude.advanced(by: -0.0001))
                let loc5 = CLLocation(latitude: location.coordinate.latitude.advanced(by: -0.00029), longitude: location.coordinate.longitude.advanced(by: 0.0002))
                
                mapView.addAnnotation( Tailgate(title: "My dope ass tailgate", school: "psu", owner: "Michael Onjack", coordinate: loc1.coordinate) )
                mapView.addAnnotation( Tailgate(title: "Tailgate w/ titties", school: "psu", owner: "Ben Hagan", coordinate: loc2.coordinate) )
                mapView.addAnnotation( Tailgate(title: "Tailgate w/ extra titties", school: "psu", owner: "Ben Hagan", coordinate: loc3.coordinate) )
                mapView.addAnnotation( Tailgate(title: "Dumb fucking tailgate", school: "osu", owner: "Ben Hagan", coordinate: loc4.coordinate) )
                mapView.addAnnotation( Tailgate(title: "Muffin workout sesh", school: "psu", owner: "Muffin Lawler", coordinate: loc5.coordinate) )
            }
        }
    }
    
    
    
    /////////////////////////////////////////////////////
    //
    //  locationServiceIsEnabled
    //
    //  Returns true if the user has location services enabled, false otherwise
    //
    func locationServiceIsEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
}
