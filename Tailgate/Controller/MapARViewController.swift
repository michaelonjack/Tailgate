//
//  MapARViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 6/17/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import CoreLocation

class MapARViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation() {
        didSet {
            print("userLocation: \(userLocation)")
        }
    }
    var tailgateLocation:CLLocation!
    var distance : Float! = 0.0 {
        didSet {
            setStatusText()
            print("distance: \(distance)")
        }
    }
    
    var modelNode:SCNNode!
    let rootNodeName = "StopSign"
    var originalTransform:SCNMatrix4!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        
        // Start location services
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // The option gravityAndHeading will set the y-axis to the direction of gravity as detected by the device, and the x- and z-axes to the longitude and latitude directions as measured by Location Services.
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop updating the location
        self.locationManager.stopUpdatingLocation()
        
        // Pause the view's session
        //sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setStatusText() {
        let text = "Distance: \(String(format: "%.2f meters", self.distance))"
        self.distanceLabel.text = text
    }

    func userLocationUpdated() {
        self.distance  = Float(self.tailgateLocation.distance(from: self.userLocation))
        
        
        // If this is the first update received, self.modelNode will be nil, so you have to instantiate the model
        if self.modelNode == nil {
            let modelScene = SCNScene(named: "art.scnassets/stopsign.dae")!
            print(modelScene)
            let parentNode:SCNNode = SCNNode()
            parentNode.name = "fullstopsign"
            parentNode.addChildNode(modelScene.rootNode.childNode(withName: "StopSign", recursively: true)!)
            parentNode.addChildNode(modelScene.rootNode.childNode(withName: "Bolt", recursively: true)!)
            parentNode.addChildNode(modelScene.rootNode.childNode(withName: "Bolt2", recursively: true)!)
            parentNode.addChildNode(modelScene.rootNode.childNode(withName: "Pole", recursively: true)!)
            self.modelNode = parentNode
            
            // Move model's pivot to its center in the Y axis
            let (minBox, maxBox) = self.modelNode.boundingBox
            self.modelNode.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y)/2, 0)
            
            // Save original transform to calculate future rotations
            self.originalTransform = self.modelNode.transform
            
            // Position the model in the correct place
            positionModel(self.tailgateLocation)
            
            // Add the model to the scene
            sceneView.scene.rootNode.addChildNode(self.modelNode)
        }
        
        else {
            // Begin animation
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            
            // Position the model in the correct place
            positionModel(self.tailgateLocation)
            
            // End animation
            SCNTransaction.commit()
        }
    }
    
}



extension MapARViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Implementing this method is required
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            
            self.userLocationUpdated()
        }
    }
}



extension MapARViewController: ARSCNViewDelegate {
    func positionModel(_ location: CLLocation) {
        // Translate node
        self.modelNode.position = translateNode(location)
        
        // Scale node
        self.modelNode.scale = scaleNode(location)
    }
    
    
    
    func rotateNode(_ angleInRadians: Float, _ transform: SCNMatrix4) -> SCNMatrix4 {
        let rotation = SCNMatrix4MakeRotation(angleInRadians, 0, 1, 0)
        return SCNMatrix4Mult(transform, rotation)
    }
    
    func scaleNode (_ location: CLLocation) -> SCNVector3 {
        let scale = min( max( Float(1000/distance), 1.5 ), 3 )
        return SCNVector3(x: scale, y: scale, z: scale)
    }
    
    func translateNode (_ location: CLLocation) -> SCNVector3 {
        let locationTransform =
            transformMatrix(matrix_identity_float4x4, userLocation, location)
        return positionFromTransform(locationTransform)
    }
    
    func positionFromTransform(_ transform: simd_float4x4) -> SCNVector3 {
        return SCNVector3Make(
            transform.columns.3.x, transform.columns.3.y, transform.columns.3.z
        )
    }
    
    func transformMatrix(_ matrix: simd_float4x4, _ originLocation: CLLocation, _ driverLocation: CLLocation) -> simd_float4x4 {
        let bearing = bearingBetweenLocations(userLocation, driverLocation)
        let rotationMatrix = rotateAroundY(matrix_identity_float4x4, Float(bearing))
        
        let position = vector_float4(0.0, 0.0, -distance, 0.0)
        let translationMatrix = getTranslationMatrix(matrix_identity_float4x4, position)
        
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        
        return simd_mul(matrix, transformMatrix)
    }
    
    func getTranslationMatrix(_ matrix: simd_float4x4, _ translation : vector_float4) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
        var matrix = matrix
        
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    func bearingBetweenLocations(_ originLocation: CLLocation, _ driverLocation: CLLocation) -> Double {
        let lat1 = originLocation.coordinate.latitude.toRadians()
        let lon1 = originLocation.coordinate.longitude.toRadians()
        
        let lat2 = driverLocation.coordinate.latitude.toRadians()
        let lon2 = driverLocation.coordinate.longitude.toRadians()
        
        let longitudeDiff = lon2 - lon1
        
        let y = sin(longitudeDiff) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longitudeDiff);
        
        return atan2(y, x)
    }
}



extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}
