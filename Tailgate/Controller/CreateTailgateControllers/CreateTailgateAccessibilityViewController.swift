//
//  CreateTailgateAccessibilityViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/16/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class CreateTailgateAccessibilityViewController: UIViewController {

    @IBOutlet weak var privateLabel: UILabel!
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var privacySwitch: UISwitch!
    
    var tailgateName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        privateLabel.isHidden = true
        privacySwitch.backgroundColor = UIColor.red
        privacySwitch.layer.cornerRadius = 16.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            privateLabel.isHidden = true
            publicLabel.isHidden = false
        }
        
        else {
            privateLabel.isHidden = false
            publicLabel.isHidden = true
        }
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "AccessibilityToDate", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dateVC: CreateTailgateDateViewController = segue.destination as! CreateTailgateDateViewController
        dateVC.tailgateName = self.tailgateName
        dateVC.isPublic = privacySwitch.isOn
    }

}
