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
import HDAugmentedReality

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager = CLLocationManager()
    fileprivate var arViewController: ARViewController!
    var tailgates: [Tailgate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        mapView.delegate = self
        
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
        
        // you grab the Tailgate object that this tap refers to
        let tailgate = view.annotation as! Tailgate
        
        arViewController = ARViewController()
        // First the dataSource for the arViewController is set. The dataSource provides views for visible POIs
        arViewController.dataSource = self
        
        arViewController.setAnnotations( [TailgateAR(location: tailgate.location, name: tailgate.title!, school: tailgate.school, owner: tailgate.owner)!] )
        
        // show the AR view
        self.present(arViewController, animated: true, completion: nil)
    }
}



extension MapViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = TailgateAnnotationARView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 250, height: 100)
        
        return annotationView
    }
}



extension MapViewController: AnnotationViewDelegate {
    func didTouch(annotationView: TailgateAnnotationARView) {
        // First you cast annotationViews annotation to a Tailgate
        if let annotation = annotationView.annotation as? TailgateAR {
            self.showInfoView(forTailgate: annotation)
        }
    }
    
    func showInfoView(forTailgate tailgate: TailgateAR) {
        // To show the additional info you create an alert view with the POIs name as title and an info text as message
        let alert = UIAlertController(title: tailgate.name , message: tailgate.description, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // Since ViewController is not a part of the view hirarchy right now, you use arViewController to show the alert
        arViewController.present(alert, animated: true, completion: nil)
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
                
                mapView.addAnnotation( Tailgate(title: "My dope ass tailgate", school: "psu", owner: "Michael Onjack", location: loc1) )
                mapView.addAnnotation( Tailgate(title: "Tailgate2", school: "psu", owner: "Ben Hagan", location: loc2) )
                mapView.addAnnotation( Tailgate(title: "Tailgate3", school: "psu", owner: "Ben Hagan", location: loc3) )
                mapView.addAnnotation( Tailgate(title: "Tailgate4", school: "osu", owner: "Ben Hagan", location: loc4) )
                mapView.addAnnotation( Tailgate(title: "Muffin workout sesh", school: "psu", owner: "Muffin Lawler", location: loc5) )
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
