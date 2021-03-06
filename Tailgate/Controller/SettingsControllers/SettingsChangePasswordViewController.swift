//
//  SettingsChangePasswordViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/2/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NotificationBannerSwift

class SettingsChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        // Change font and color of nav header
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0), NSAttributedString.Key.foregroundColor: UIColor.white]
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
            
            firUser?.reauthenticate(with: credential, completion: { (result, error) in
                // User entered the correct password
                if error == nil {
                    // New password and confirmation password match
                    if newPassword == confirmNewPassword {
                        firUser?.updatePassword(to: newPassword, completion: { (error) in
                            if error == nil {
                                // Password successfully changed, update the keychain
                                updateKeychainCredentials(email: currentUser.email, password: newPassword)
                                
                                // Show success notification banner
                                DispatchQueue.main.async {
                                    let successBanner = NotificationBanner(attributedTitle: NSAttributedString(string: "Password Updated"), attributedSubtitle: NSAttributedString(string: "Your password has been successfully updated!"), style: .success)
                                    successBanner.show()
                                }
                            } else {
                                let errorAlert = createAlert(title: "Cannot Change Password", message: (error?.localizedDescription)!)
                                self.present(errorAlert, animated: true, completion: nil)
                            }
                        })
                    } else {
                        let incorrectPassAlert = createAlert(title: "Password Mismatch", message: "Your new password does not match the confirm password.")
                        self.present(incorrectPassAlert, animated: true, completion: nil)
                    }
                } else {
                    let incorrectPassAlert = createAlert(title: "Incorrect Password", message: "The current password you entered is incorrect.")
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
                        let resetPassAlert = createAlert(title: "Reset Email Sent", message: "An email to reset your password has been sent to " + userEmail)
                        
                        self.present(resetPassAlert, animated: true, completion:nil)
                    }
                        
                    // If an error is encountered, show error description in alert
                    else {
                        let errorAlert = createAlert(title: "Error Sending Reset Email", message: (error?.localizedDescription)!)
                        
                        self.present(errorAlert, animated: true, completion:nil)
                    }
                })
            }
            
        })
    }
}


