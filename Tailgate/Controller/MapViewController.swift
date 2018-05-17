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
    var tailgates: [TailgateAnnotation] = []
    
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
        // Dispose of any resources that can be recreated.
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
            
            arViewController = ARViewController()
            // First the dataSource for the arViewController is set. The dataSource provides views for visible POIs
            arViewController.dataSource = self
            
            arViewController.setAnnotations( [TailgateAnnotationAR(location: tailgate.location, name: tailgate.title!, school: tailgate.school, owner: tailgate.owner)!] )
            
            // show the AR view
            self.present(arViewController, animated: true, completion: nil)
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
        if let annotation = annotationView.annotation as? TailgateAnnotationAR {
            self.showInfoView(forTailgate: annotation)
        }
    }
    
    func showInfoView(forTailgate tailgate: TailgateAnnotationAR) {
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
                let loc2 = CLLocation(latitude: location.coordinate.latitude.advanced(by: 0.0026), longitude: location.coordinate.longitude.advanced(by: -0.00016))
                let loc3 = CLLocation(latitude: location.coordinate.latitude.advanced(by: 0.0005), longitude: location.coordinate.longitude.advanced(by: 0.0005))
                let loc4 = CLLocation(latitude: location.coordinate.latitude.advanced(by: -0.0004), longitude: location.coordinate.longitude.advanced(by: -0.0005))
                let loc5 = CLLocation(latitude: location.coordinate.latitude.advanced(by: -0.00029), longitude: location.coordinate.longitude.advanced(by: 0.0002))
                let loc6 = CLLocation(latitude: location.coordinate.latitude.advanced(by: 0.0008), longitude: location.coordinate.longitude.advanced(by: -0.001))
                
                mapView.addAnnotation( TailgateAnnotation(id:"1", title: "My dope ass tailgate", school: "Penn State University", flairImageUrl: "https://firebasestorage.googleapis.com/v0/b/tailgate-53761.appspot.com/o/images%2FPennStateUniversity%2Fflair%2Fflair1.png?alt=media&token=4e99e90f-998b-4efb-a4d7-817c46e923e6", owner: "Michael Onjack", location: loc1) )
                mapView.addAnnotation( TailgateAnnotation(id:"2", title: "Tailgate2", school: "Penn State University", flairImageUrl: "https://firebasestorage.googleapis.com/v0/b/tailgate-53761.appspot.com/o/images%2FPennStateUniversity%2Fflair%2Fflair2.png?alt=media&token=fc3f7137-af20-4799-9dcb-d600d58ce77e", owner: "Ben Hagan", location: loc2) )
                mapView.addAnnotation( TailgateAnnotation(id:"3", title: "Dopest tailgate", school: "Penn State University", flairImageUrl: "https://firebasestorage.googleapis.com/v0/b/tailgate-53761.appspot.com/o/images%2FPennStateUniversity%2Fflair%2Fflair3.png?alt=media&token=1ec173e2-2edb-406c-9d24-91c1396eb441", owner: "Ben Hagan", location: loc3) )
                mapView.addAnnotation( TailgateAnnotation(id:"4", title: "Tailgate4", school: "Penn State University", flairImageUrl: "https://firebasestorage.googleapis.com/v0/b/tailgate-53761.appspot.com/o/images%2FPennStateUniversity%2Fflair%2Fflair6.png?alt=media&token=6a5e7a90-525d-415c-a50c-df1013a471ea", owner: "Ben Hagan", location: loc4) )
                mapView.addAnnotation( TailgateAnnotation(id:"5", title: "Tailgate4", school: "Penn State University", flairImageUrl: "https://firebasestorage.googleapis.com/v0/b/tailgate-53761.appspot.com/o/images%2FPennStateUniversity%2Fflair%2Fflair5.png?alt=media&token=62ff7e75-cc69-4b2e-a8fe-851bb7fc21a8", owner: "Ben Hagan", location: loc5) )
                mapView.addAnnotation( TailgateAnnotation(id:"6", title: "Tailgate5", school: "Penn State University", flairImageUrl: "https://firebasestorage.googleapis.com/v0/b/tailgate-53761.appspot.com/o/images%2FPennStateUniversity%2Fflair%2Fflair8.png?alt=media&token=a89160a2-41e3-4048-8894-8fe936a20034", owner: "Ben Hagan", location: loc6) )
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
