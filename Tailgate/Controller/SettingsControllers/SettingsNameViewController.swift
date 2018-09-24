//
//  SettingsNameViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/3/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class SettingsNameViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: PaddedTextField!
    @IBOutlet weak var lastNameTextField: PaddedTextField!
    
    var presentingController: UIViewController?
    var firstName:String?
    var lastName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firstNameTextField.text = self.firstName
        self.lastNameTextField.text = self.lastName

        // Change font and color of nav header
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0), NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func updateButtonPressed(_ sender: Any) {
        updateValueForCurrentUser(key: "firstName", value: self.firstNameTextField.text ?? "")
        updateValueForCurrentUser(key: "lastName", value: self.lastNameTextField.text ?? "")
        
        // Update the Settings table
        if let presentingController = self.presentingController as? SettingsViewController {
            presentingController.loadData()
            self.navigationController?.popViewController(animated: true)
        }
    }
}
