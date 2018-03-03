//
//  SettingsChangePasswordViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/2/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase

class SettingsChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Change font and color of nav header
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22.0), NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func updatePasswordPressed(_ sender: Any) {
        let firUser = Auth.auth().currentUser
        let currentPassword = self.currentPasswordTextField.text ?? ""
        let newPassword = self.newPasswordTextField.text ?? ""
        let confirmNewPassword = self.confirmNewPasswordTextField.text ?? ""
        
        getUserById(userId: (firUser!.uid)) { (currentUser) in
            let credential = EmailAuthProvider.credential(withEmail: currentUser.email, password: currentPassword)
            
            firUser?.reauthenticate(with: credential, completion: { (error) in
                // User entered the correct password
                if error == nil {
                    if newPassword == confirmNewPassword {
                        firUser?.updatePassword(to: newPassword, completion: { (error) in
                            if error == nil {
                                // Update keychain eventually
                            } else {
                                let errorAlert = self.createAlert(title: "Cannot Change Password", message: (error?.localizedDescription)!)
                                self.present(errorAlert, animated: true, completion: nil)
                            }
                        })
                    } else {
                        let incorrectPassAlert = self.createAlert(title: "Password Mismatch", message: "Your new password does not match the confirm password.")
                        self.present(incorrectPassAlert, animated: true, completion: nil)
                    }
                } else {
                    let incorrectPassAlert = self.createAlert(title: "Incorrect Password", message: "The current password you entered is incorrect.")
                    self.present(incorrectPassAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        let currentUserReference = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
        
        currentUserReference.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get the current user's email address
            let currentUser = snapshot.value as? NSDictionary
            if let userEmail = currentUser?["email"] as? String {
                Auth.auth().sendPasswordReset(withEmail: userEmail, completion: { (error) in
                    
                    // If no error, send a reset password email
                    if error == nil {
                        let resetPassAlert = self.createAlert(title: "Reset Email Sent", message: "An email to reset your password has been sent to " + userEmail)
                        
                        self.present(resetPassAlert, animated: true, completion:nil)
                    }
                        
                    // If an error is encountered, show error description in alert
                    else {
                        let errorAlert = self.createAlert(title: "Error Sending Reset Email", message: (error?.localizedDescription)!)
                        
                        self.present(errorAlert, animated: true, completion:nil)
                    }
                })
            }
            
        })
    }
    
    
    func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .default)
        alert.addAction(closeAction)
        
        return alert
    }
}

class PaddedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
