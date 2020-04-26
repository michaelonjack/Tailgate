//
//  SignUpAgreementViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 5/22/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwipeNavigationController

class SignUpAgreementViewController: UIViewController {
    
    @IBOutlet weak var termsLabel: UILabel!
    
    var passwordItems: [KeychainPasswordItem] = []
    var firstName: String!
    var lastName: String!
    var email: String!
    var password: String!
    
    let usersDatabase = Database.database().reference(withPath: "users")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let attributedText = NSMutableAttributedString(attributedString: self.termsLabel.attributedText!)
        
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold)], range: getRangeOfSubString(subString: "Terms of Service", fromString: self.termsLabel.text!))
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], range: getRangeOfSubString(subString: "Who Can Use Tailgator", fromString: self.termsLabel.text!))
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], range: getRangeOfSubString(subString: "Content", fromString: self.termsLabel.text!))
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], range: getRangeOfSubString(subString: "Respecting Other People’s Rights", fromString: self.termsLabel.text!))
        
        self.termsLabel.attributedText = attributedText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func getRangeOfSubString(subString: String, fromString: String) -> NSRange {
        let sampleLinkRange = fromString.range(of: subString)!
        let startPos = fromString.distance(from: fromString.startIndex, to: sampleLinkRange.lowerBound)
        let endPos = fromString.distance(from: fromString.startIndex, to: sampleLinkRange.upperBound)
        let linkRange = NSMakeRange(startPos, endPos - startPos)
        
        return linkRange
    }
    
    

    @IBAction func agreePressed(_ sender: Any) {
        // Create a user using the user's provided email and password
        Auth.auth().createUser(withEmail: self.email, password: self.password) { authResult, error in
            
            if error == nil {
                
                updateKeychainCredentials(email: self.email, password: self.password)
                
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
                let gamedayViewController = mainStoryboard.instantiateViewController(withIdentifier: "GamedayContainerViewController") as! GamedayContainerViewController
                
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
                    swipeNavigationController.modalPresentationStyle = .fullScreen
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
