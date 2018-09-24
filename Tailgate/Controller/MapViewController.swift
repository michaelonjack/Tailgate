//
//  MapViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/9/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import ARKit
import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager = CLLocationManager()
    var tailgates: [TailgateAnnotation] = []
    var selectedTailgate: TailgateAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        mapView.delegate = self
        
        addTailgateAnnotations()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.showsUserLocation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.showsUserLocation = false
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
        
        // Animate the button with a 360 spin to give user feedback
        UIView.animate(withDuration: 0.3) {
            sender.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
        }, completion: nil)
        
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
            if locationServiceIsEnabled() {
                // you grab the Tailgate object that this tap refers to
                let tailgate = view.annotation as! TailgateAnnotation
                self.selectedTailgate = tailgate
                self.performSegue(withIdentifier: "MapToAR", sender: nil)
            }
            
            else {
                let locationNotEnabledAlert = createAlert(title: "Location Services Disabled", message: "Location services are required to use augmented reality.")
                self.present(locationNotEnabledAlert, animated: true, completion: nil)
            }
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
    
    
    
    // Called every time the map needs to show an annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Define a reuse identifier.
        // This is a string that will be used to ensure we reuse annotation views as much as possible
        let identifier = "Tailgate"
        
        // Check whether the annotation we're creating a view for is one of our tailgate annotation
        if let tailgateAnnotation = annotation as? TailgateAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: tailgateAnnotation, reuseIdentifier: identifier)
                
                annotationView!.canShowCallout = true
                annotationView!.calloutOffset = CGPoint(x: -5, y: 5)
                
                // Only show the AR button in the callout if AR is supported by the user's device
                if ARWorldTrackingConfiguration.isSupported {
                    // Here, you create a UIButton, set its background image to the AR icon, then set the view’s right callout accessory to this button
                    let arButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                            size: CGSize(width: 30, height: 30)))
                    arButton.setBackgroundImage(UIImage(named: "AR"), for: UIControl.State())
                    annotationView!.rightCalloutAccessoryView = arButton
                }
                
                // Here, you create a UIButton, set its background image to the Open icon, then set the view’s left callout accessory to this button
                let infoButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                        size: CGSize(width: 30, height: 30)))
                infoButton.setBackgroundImage(UIImage(named: "Open"), for: UIControl.State())
                annotationView!.leftCalloutAccessoryView = infoButton
            }
                
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = tailgateAnnotation.owner
            annotationView!.detailCalloutAccessoryView = detailLabel
            
            let schoolPath = tailgateAnnotation.school.replacingOccurrences(of: " ", with: "")
            let schoolReference = Database.database().reference(withPath: "schools/" + schoolPath)
            schoolReference.observeSingleEvent(of: .value, with: { (snapshot) in
                let dataDict = snapshot.value as? NSDictionary
                
                if snapshot.hasChild("annotationImageUrl") {
                    let flairUrlStr = tailgateAnnotation.flairImageUrl
                    let picUrlStr = dataDict?["annotationImageUrl"] as? String ?? ""
                    
                    if flairUrlStr != "" {
                        let picUrl = URL(string: flairUrlStr)
                        annotationView!.sd_setImage(with: picUrl, completed: nil)
                    }
                        
                    else if picUrlStr != "" {
                        let picUrl = URL(string: picUrlStr)
                        annotationView!.sd_setImage(with: picUrl, completed: nil)
                    }
                }
            })
            
            return annotationView
        }
        
        return nil
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
