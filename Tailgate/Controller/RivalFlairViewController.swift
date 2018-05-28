//
//  RivalFlairViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 4/21/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class RivalFlairViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func questionButtonPressed(_ sender: Any) {
        let alert = createAlert(title: "What's rival flair?", message: "Every few weeks we'll force your rivals to use the flair that you've submitted. Make it hurt.")
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
