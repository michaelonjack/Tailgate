//
//  ViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/9/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If a user is already logged in, skip login view and continue to their profile
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil { //}&& (user?.isEmailVerified)! {
                self.performSegue(withIdentifier: "LoginToProfile", sender: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            if let user = Auth.auth().currentUser {
                self.performSegue(withIdentifier: "LoginToProfile", sender: nil)
            }
            
            // Login failed -- show error message
            else {
                let errorAlert = UIAlertController(title: "",
                                                   message: error?.localizedDescription,
                                                   preferredStyle: .alert)
                
                let closeAction = UIAlertAction(title: "Close", style: .default)
                errorAlert.addAction(closeAction)
                self.present(errorAlert, animated: true, completion:nil)
            }
        }
    }
    
}

