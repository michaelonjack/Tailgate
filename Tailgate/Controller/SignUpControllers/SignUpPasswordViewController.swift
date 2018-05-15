//
//  SignUpPasswordViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/10/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwipeNavigationController

class SignUpPasswordViewController: UIViewController {
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    var passwordItems: [KeychainPasswordItem] = []
    var firstName: String!
    var lastName: String!
    var email: String!
    
    let usersDatabase = Database.database().reference(withPath: "users")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
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
                Auth.auth().createUser(withEmail: email, password: pass) { authResult, error in
                    
                    if error == nil {
                        
                        updateKeychainCredentials(email: self.email, password: pass)
                        
                        let user = authResult?.user
                        
                        let newUser = User(
                            user: user!,
                            firstName: self.firstName,
                            lastName: self.lastName
                        )
                        let newUserRef = self.usersDatabase.child((user?.uid)!)
                        
                        newUserRef.setValue(newUser.toAnyObject())
                        
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
                        
                        DispatchQueue.main.async {
                            self.present(swipeNavigationController, animated: true, completion: nil)
                        }
                    
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
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.nextButtonBottomConstraint.constant == 0 {
                self.nextButtonBottomConstraint.constant -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.nextButtonBottomConstraint.constant = 0
    }
    
    
    
    /////////////////////////////////////////////////////
    //
    //  touchesBegan
    //
    //  Hides the keyboard when the user selects a non-textfield area
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}
