//
//  SettingsBirthdayViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/3/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase

class SettingsBirthdayViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var birthdayTextField: PaddedTextField!
    @IBOutlet weak var updateButton: UIButton!
    
    let dateFormatter = DateFormatter()
    var presentingController: UIViewController?
    var initialDateString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateButton.isHidden = true
        self.birthdayTextField.text = self.initialDateString
        
        dateFormatter.dateStyle = .long
        self.datePicker.backgroundColor = .white
        self.datePicker.date = dateFormatter.date(from: initialDateString) ?? Date()
        
        // Change font and color of nav header
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22.0), NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let selectedDate = dateFormatter.string(from: sender.date)
        
        self.updateButton.isHidden = false
        self.birthdayTextField.text = selectedDate
    }
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        updateValueForCurrentUser(key: "birthday", value: self.birthdayTextField.text ?? "")
        
        // Update the Settings table
        if let presentingController = self.presentingController as? SettingsViewController {
            presentingController.loadData()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}