//
//  SignUpViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/10/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class SignUpNameViewController: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func nextPressed(_ sender: UIButton) {
        if firstName.text! != "" && lastName.text! != "" {
            self.performSegue(withIdentifier: "NameToEmail", sender: nil)
        }
        
        else {
            let errorAlert = UIAlertController(
                title: "",
                message: "First and last name are required",
                preferredStyle: .alert
            )
            
            let closeAction = UIAlertAction(title: "Close", style: .default)
            errorAlert.addAction(closeAction)
            self.present(errorAlert, animated: true, completion:nil)
        }
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
        let emailVC: SignUpEmailViewController = segue.destination as! SignUpEmailViewController
        emailVC.firstName = self.firstName.text!
        emailVC.lastName = self.lastName.text!
    }
}
