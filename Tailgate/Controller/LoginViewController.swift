//
//  ViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/9/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase
import SwipeNavigationController

class LoginViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statusLabel.isHidden = true
        self.forgotPasswordButton.isHidden = true
        
        // If a user is already logged in, skip login view and continue to their profile
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil { //}&& (user?.isEmailVerified)! {
                let swipeNavigationController = self.createSwipeController()
                
                DispatchQueue.main.async {
                    self.present(swipeNavigationController, animated: true, completion: nil)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    /////////////////////////////////////////////////////
    //
    //  loginDidTouch
    //
    //  Handles the action when the login button is pressed
    //  Uses the supplied email and password to give access to the current user to the app
    //
    @IBAction func loginPressed(_ sender: Any) {
        let email = loginEmail.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let password = loginPassword.text!
        
        Auth.auth().signIn(withEmail: email, password: password) {user,  error in
            if let _ = Auth.auth().currentUser {
                
                let swipeNavigationController = self.createSwipeController()
                
                DispatchQueue.main.async {
                    self.present(swipeNavigationController, animated: true, completion: nil)
                }
            }
            
            // Login failed -- show error message
            else {
                // Show the Forgot Password button
                DispatchQueue.main.async {
                    self.statusLabel.textColor = .red
                    self.statusLabel.text = error?.localizedDescription
                    self.statusLabel.isHidden = false
                    self.forgotPasswordButton.isHidden = false
                }
            }
        }
    }
    
    
    
    /////////////////////////////////////////////////////
    //
    // forgotPasswordPressed
    //
    //
    //
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        
        if let email = self.loginEmail.text, email != "" {
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                // If no error, send a reset password email
                if error == nil {
                    self.statusLabel.textColor = .green
                    self.statusLabel.text = "An email to reset your password has been sent"
                    self.statusLabel.isHidden = false
                }
                
                else {
                    self.statusLabel.textColor = .red
                    self.statusLabel.text = error?.localizedDescription
                    self.statusLabel.isHidden = false
                }
            })
        }
        
        // Ask user to fill in the email field
        else {
            self.statusLabel.textColor = .red
            self.statusLabel.text = "Fill in the email field to reset your password"
            self.statusLabel.isHidden = false
        }
    }
    
    
    
    func createSwipeController() -> SwipeNavigationController {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let tailgateViewController = mainStoryboard.instantiateViewController(withIdentifier: "TailgateViewController") as! TailgateViewController
        let newTailgateViewController = mainStoryboard.instantiateViewController(withIdentifier: "NewTailgateNavigationController") as! UINavigationController
        let mapViewController = mainStoryboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        let gamedayViewController = mainStoryboard.instantiateViewController(withIdentifier: "ScheduleNavigationController") as! UINavigationController
        
        let swipeNavigationController = SwipeNavigationController(centerViewController: profileViewController)
        swipeNavigationController.leftViewController = mapViewController
        swipeNavigationController.topViewController = gamedayViewController
        swipeNavigationController.shouldShowTopViewController = true
        swipeNavigationController.shouldShowBottomViewController = false
        
        // Determine which tailgate controller the user should see when they swipe right
        let userReference = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
        userReference.observeSingleEvent(of: .value, with: { (snapshot) in
            // If the user already has a tailgate, show them the controller for an existing one
            if snapshot.hasChild("tailgate") {
                let snapshotValue = snapshot.value as! [String: AnyObject]
                let tailgateId = snapshotValue["tailgate"] as? String ?? ""
                let tailgateReference = Database.database().reference(withPath: "tailgates/" + tailgateId)
                
                tailgateReference.observeSingleEvent(of: .value, with: { (snapshot) in
                    let userTailgate = Tailgate(snapshot: snapshot)
                    tailgateViewController.tailgate = userTailgate
                    swipeNavigationController.rightViewController = tailgateViewController
                })
            }
                
                // Else show them the controller to create a new one
            else {
                swipeNavigationController.rightViewController = newTailgateViewController
            }
        })
        
        return swipeNavigationController
    }
}

