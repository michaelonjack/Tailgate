//
//  CreateTailgateNameViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/16/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class CreateTailgateNameViewController: UIViewController {

    @IBOutlet weak var tailgateName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        
        if tailgateName.text != "" {
            self.performSegue(withIdentifier: "NameToSchool", sender: nil)
        }
        
        else {
            let errorAlert = UIAlertController(
                title: "",
                message: "Name is required",
                preferredStyle: .alert
            )
            
            let closeAction = UIAlertAction(title: "Close", style: .default)
            errorAlert.addAction(closeAction)
            self.present(errorAlert, animated: true, completion:nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let accVC: CreateTailgateSchoolViewController = segue.destination as! CreateTailgateSchoolViewController
        accVC.tailgateName = self.tailgateName.text!
    }

}
