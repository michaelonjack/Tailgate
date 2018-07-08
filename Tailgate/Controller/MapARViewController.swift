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

enum ARState {
    case notAvailable
    case initializing
    case excessiveMotion
    case insufficientFeatures
    case resuming
    case calculatingDistance
    case distanceCalculated
}

class MapARViewController: UIViewController {

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation() {
        didSet {
            print("userLocation: \(userLocation)")
        }
    }
    var tailgateLocation:CLLocation!
    var distance : Float! = 0.0
    var state = ARState.initializing {
        didSet {
            setStatusText()
        }
    }
    
    var modelNode:SCNNode!
    var directionNode:SCNNode!
    // The stop sign model is at a 1/0.083 scale so in order to get an accurate distance
    // we'll scale the matrix by 1/0.083
    let modelNodeScale:Float = 12.0481927711
    let rootNodeName = "stopsign"
    var originalTransform:SCNMatrix4!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        
        // Modify buttons
        closeButton.layer.borderWidth = 1.0
        closeButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.7).cgColor
        closeButton.layer.cornerRadius = 5.0
        resetButton.layer.borderWidth = 1.0
        resetButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.7).cgColor
        resetButton.layer.cornerRadius = 5.0
        
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        // Remove any existing nodes from the scene
        self.modelNode.removeFromParentNode()
        self.directionNode.removeFromParentNode()
        self.modelNode = nil
        self.directionNode = nil
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func setStatusText() {
        
        switch(self.state) {
        case .initializing:
            self.distanceLabel.text = "Initializing..."
        case .calculatingDistance:
            self.distanceLabel.text = "Calculating distance..."
        case .distanceCalculated:
            let text = "Distance: \(String(format: "%.2f meters", self.distance))"
            self.distanceLabel.text = text
        case .excessiveMotion:
            self.distanceLabel.text = "Excessive motion. Try holding your device steady for a few seconds."
        case .insufficientFeatures:
            self.distanceLabel.text = "Insufficient features. Try moving your device around to find more objects in space"
        case .resuming:
            self.distanceLabel.text = "Resuming..."
        case .notAvailable:
            self.distanceLabel.text = "Augmented Reality not available."
        }
    }

    func userLocationUpdated() {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        self.distance  = Float(self.tailgateLocation.distance(from: self.userLocation))
        self.state = .distanceCalculated
        
        // If this is the first update received, self.modelNode will be nil, so you have to instantiate the model
        if self.modelNode == nil {
            let modelScene = SCNScene(named: "art.scnassets/stopsign.dae")!
            self.modelNode = modelScene.rootNode.childNode(withName: rootNodeName, recursively: true)!
            
            // Move model's pivot to its center in the Y axis
            let (minBox, maxBox) = self.modelNode.boundingBox
            self.modelNode.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y)/2, 0)
            
            // Save original transform to calculate future rotations
            self.originalTransform = self.modelNode.transform
            
            // Add the model to the scene
            sceneView.scene.rootNode.addChildNode(self.modelNode)
            
            var userTranslationTransform = matrix_identity_float4x4
            userTranslationTransform.columns.3.x = currentFrame.camera.transform.columns.3.x // left right
            userTranslationTransform.columns.3.y = currentFrame.camera.transform.columns.3.y // back!
            userTranslationTransform.columns.3.z = currentFrame.camera.transform.columns.3.z // up
            print("userTranslationTransform: \(userTranslationTransform)")
            
            let bearingDegrees = bearingBetweenLocations(userLocation, tailgateLocation)
            print("bearing: \(bearingDegrees)")
            let rotationMatrix = rotateAroundZ(matrix_identity_float4x4, Float(bearingDegrees))
            print("rotationMatrix: \(rotationMatrix)")
            
            let position = vector_float4(0.0, -(distance), 0.0, 0.0)
            let translationMatrix = getTranslationMatrix(matrix_identity_float4x4, position)
            print("translationMatrix: \(translationMatrix)")
            
            var combinedMatrix = simd_mul(rotationMatrix, translationMatrix)
            combinedMatrix.columns.3.x = combinedMatrix.columns.3.x * modelNodeScale
            combinedMatrix.columns.3.y = combinedMatrix.columns.3.y * modelNodeScale
            combinedMatrix.columns.3.z = combinedMatrix.columns.3.z * modelNodeScale
            print("combinedMatrix: \(combinedMatrix)")
            
            let transformMatrix = simd_mul(userTranslationTransform, combinedMatrix)
            
            self.modelNode.simdTransform = matrix_multiply(self.modelNode.simdTransform, transformMatrix)
            
            
            
            // Construct the direction node to lead the user to their destination
            let directionNodeGeomety = SCNBox(width: self.sceneView.bounds.height / 6000, height: self.sceneView.bounds.height / 6000, length: 0, chamferRadius: 0)
            directionNodeGeomety.firstMaterial?.diffuse.contents = UIImage(named: "PointEmoji")
            self.directionNode = SCNNode(geometry: directionNodeGeomety)
            
            // Add the node to the scene
            self.sceneView.scene.rootNode.addChildNode(self.directionNode)
            
            // Place the node 0.7 meters from the user
            var dirTranslationMatrix = matrix_identity_float4x4
            dirTranslationMatrix.columns.3.z = -0.7
            
            // Rotate the destination node so it's in line with the stop sign node
            let dirRotationMatrix = rotateAroundY(matrix_identity_float4x4, Float(bearingDegrees))
            
            // Create the transform using these two matrices
            let directionNodeTransform = simd_mul(dirRotationMatrix, dirTranslationMatrix)
            
            // Apply the transform to the direction node to put it in place
            self.directionNode.simdTransform = simd_mul(userTranslationTransform, directionNodeTransform)
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
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch(camera.trackingState) {
        case .normal:
            if distance != 0.0 {
                self.state = ARState.distanceCalculated
            } else {
                self.state = ARState.calculatingDistance
            }
        case .notAvailable:
            self.state = ARState.notAvailable
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                self.state = ARState.excessiveMotion
            case .insufficientFeatures:
                self.state = ARState.insufficientFeatures
            case .initializing:
                self.state = ARState.initializing
            case .relocalizing:
                self.state = ARState.resuming
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        guard let _ = self.directionNode else {
            return
        }
        
        // When the user gets too close to the direction indicator node, we want to reposition the node
        // to again be 0.7 meters away from the user
        // This way the direction node will lead the user to their destination
        let distanceFromDirectionNode = currentFrame.camera.transform.columns.3.z - self.directionNode.simdTransform.columns.3.z
        
        // If the user is "too close" (which we arbitrarily say is 0.03 meters)
        // and the user isn't very close to the destination, then reposition the node
        if abs(distanceFromDirectionNode) < 0.03 && self.distance > 10 {
            var directionNodeTransform = matrix_identity_float4x4
            directionNodeTransform.columns.3.z = -0.7
            
            self.directionNode.simdTransform = simd_mul(self.directionNode.simdTransform, directionNodeTransform)
        }
    }
    
    func getTranslationMatrix(_ matrix: simd_float4x4, _ translation : vector_float4) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
}


