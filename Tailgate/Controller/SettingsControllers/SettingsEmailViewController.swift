//
//  SettingsEmailViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/3/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsEmailViewController: UIViewController {

    @IBOutlet weak var emailTextField: PaddedTextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    var presentingController: UIViewController?
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailTextField.text = self.email
        self.statusLabel.isHidden = true
        
        // Change font and color of nav header
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0), NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func updateButtonPressed(_ sender: Any) {
        self.statusLabel.text = "Checking..."
        self.statusLabel.isHidden = false
        
        let email = self.emailTextField.text ?? ""
        
        Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
            if error == nil {
                updateValueForCurrentUser(key: "email", value: email)
                
                // Update the Settings table
                if let presentingController = self.presentingController as? SettingsViewController {
                    presentingController.loadData()
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                let errorAlert = createAlert(title: "Update Failed", message: (error?.localizedDescription)!)
                self.present(errorAlert, animated: true, completion:nil)
                DispatchQueue.main.async {
                    self.statusLabel.isHidden = true
                }
            }
        })
    }
}
