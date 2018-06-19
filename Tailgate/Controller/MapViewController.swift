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
    var tailgates: [TailgateAnnotation] = []
    var selectedTailgate: TailgateAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        mapView.delegate = self
        
        // register the custom tailgate view with the map view’s default reuse identifier
        mapView.register(TailgateAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        addTailgateAnnotations()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapToAR" {
            if let arController:MapARViewController = segue.destination as? MapARViewController {
                arController.tailgateLocation = self.selectedTailgate.location
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.containerSwipeNavigationController?.showEmbeddedView(position: .center)
    }
    
    @IBAction func reloadButtonPressed(_ sender: UIButton) {
        
        // Remove any existing annotations on the map before starting
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        addTailgateAnnotations()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //
    // addTailgateAnnotations
    //
    // Adds annotations for all tailgates in the database
    //
    func addTailgateAnnotations() {
        getTailgatesToDisplay { (tailgates) in
            for tailgate in tailgates {
                if let _ = tailgate.location {
                    getUserById(userId: tailgate.ownerId, completion: { (owner) in
                        tailgate.owner = owner
                        self.mapView.addAnnotation(TailgateAnnotation(tailgate: tailgate))
                    })
                }
            }
        }
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //
    // removeAnnotation
    //
    // Removes the annotation for the parameter tailgate
    //
    func removeAnnotation(tailgate:Tailgate) {
        for annotation in self.mapView.annotations {
            let tailgateAnnotation:TailgateAnnotation = annotation as! TailgateAnnotation
            if tailgateAnnotation.id == tailgate.id {
                self.mapView.removeAnnotation(tailgateAnnotation)
            }
        }
    }
}



extension MapViewController: MKMapViewDelegate {
    // When the user taps a map annotation marker, the callout shows an info button.
    // If the user taps this info button, this method is called
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        // Show the AR view when the right accessory view is tapped
        if control == view.rightCalloutAccessoryView {
            // you grab the Tailgate object that this tap refers to
            let tailgate = view.annotation as! TailgateAnnotation
            self.selectedTailgate = tailgate
            self.performSegue(withIdentifier: "MapToAR", sender: nil)
        }
        
        // Show the tailgate view when the left accessory view is tapped
        else if control == view.leftCalloutAccessoryView {
            let tailgateAnnotation = view.annotation as! TailgateAnnotation
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tailgateViewController = mainStoryboard.instantiateViewController(withIdentifier: "TailgateViewController") as! TailgateViewController
            tailgateViewController.tailgate = tailgateAnnotation.tailgate
            tailgateViewController.hasFullAccess = false
            self.present(tailgateViewController, animated: true, completion: nil)
        }
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
