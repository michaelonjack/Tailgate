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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PasswordToAgreement", sender: nil)
                }
            }
            
        }
    }
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let agreementVC: SignUpAgreementViewController = segue.destination as! SignUpAgreementViewController
        agreementVC.firstName = self.firstName
        agreementVC.lastName = self.lastName
        agreementVC.email = self.email
        agreementVC.password = self.password.text!
    }
}
