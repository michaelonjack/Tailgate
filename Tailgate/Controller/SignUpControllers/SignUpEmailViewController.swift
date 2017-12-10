//
//  SignUpEmailViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/10/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class SignUpEmailViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var status: UILabel!
    var firstName: String!
    var lastName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        status.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func nextPressed(_ sender: UIButton) {
        if email.text! != "" {
            status.text = "Checking..."
            status.isHidden = false
            
            self.performSegue(withIdentifier: "EmailToPassword", sender: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let passwordVC: SignUpPasswordViewController = segue.destination as! SignUpPasswordViewController
        passwordVC.firstName = self.firstName
        passwordVC.lastName = self.lastName
        passwordVC.email = self.email.text!
    }
}
