//
//  CreateTailgateSchoolViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/16/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class CreateTailgateSchoolViewController: UIViewController {

    var tailgateName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SchoolToAccessibility", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let accVC: CreateTailgateAccessibilityViewController = segue.destination as! CreateTailgateAccessibilityViewController
        accVC.tailgateName = self.tailgateName
    }

}
