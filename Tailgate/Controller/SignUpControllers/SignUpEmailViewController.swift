//
//  SignUpEmailViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/10/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpEmailViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    var firstName: String!
    var lastName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        status.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func nextPressed(_ sender: UIButton) {
        if email.text! != "" {
            status.text = "Checking..."
            status.isHidden = false
            
            Auth.auth().fetchProviders(forEmail: email.text!, completion: { (providers, error) in
                if let providers = providers, providers.count > 0 {
                    DispatchQueue.main.async {
                        self.status.text = "Email already in use."
                    }
                } else {
                    DispatchQueue.main.async {
                        self.status.isHidden = true
                        self.performSegue(withIdentifier: "EmailToPassword", sender: nil)
                    }
                }
            })
        }
        
        else {
            let errorAlert = UIAlertController(
                title: "",
                message: "Email is required",
                preferredStyle: .alert
            )
            
            let closeAction = UIAlertAction(title: "Close", style: .default)
            errorAlert.addAction(closeAction)
            self.present(errorAlert, animated: true, completion:nil)
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
        let passwordVC: SignUpPasswordViewController = segue.destination as! SignUpPasswordViewController
        passwordVC.firstName = self.firstName
        passwordVC.lastName = self.lastName
        passwordVC.email = self.email.text!
    }
}
