//
//  SignUpPasswordViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/10/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase

class SignUpPasswordViewController: UIViewController {
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    var firstName: String!
    var lastName: String!
    var email: String!
    
    let usersDatabase = Database.database().reference(withPath: "users")

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func signUpPressed(_ sender: UIButton) {
        if let pass = password.text, let confirmPass = confirmPassword.text {
            
            if pass != confirmPass {
                let passwordAlert = UIAlertController(
                    title: "Sign Up Error",
                    message: "Passwords do not match",
                    preferredStyle: .alert
                )
                
                let closeAction = UIAlertAction(title: "Close", style: .default)
                passwordAlert.addAction(closeAction)
                self.present(passwordAlert, animated: true, completion:nil)
            }
            
            else {
                // Create a user using the user's provided email and password
                Auth.auth().createUser(withEmail: email, password: pass) { user, error in
                    
                    if error == nil {
                        
                        let newUser = User(
                            user: user!,
                            firstName: self.firstName,
                            lastName: self.lastName
                        )
                        let newUserRef = self.usersDatabase.child((user?.uid)!)
                        
                        newUserRef.setValue(newUser.toAnyObject())
                        
                        self.performSegue(withIdentifier: "SignUpToProfile", sender: nil)
                    
                    } else {
                        let errorAlert = UIAlertController(title: "Sign Up Error",
                                                           message: error?.localizedDescription,
                                                           preferredStyle: .alert)
                        
                        let closeAction = UIAlertAction(title: "Close", style: .default)
                        errorAlert.addAction(closeAction)
                        self.present(errorAlert, animated: true, completion:nil)
                    }
                    
                }
            }
            
        }
    }
}
