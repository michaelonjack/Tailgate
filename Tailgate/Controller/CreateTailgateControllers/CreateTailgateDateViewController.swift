//
//  CreateTailgateDateViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/16/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class CreateTailgateDateViewController: UIViewController {

    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startDatePicker.minimumDate = Date()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "DateToSupplies", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let suppliesVC: CreateTailgateSuppliesViewController = segue.destination as! CreateTailgateSuppliesViewController
        suppliesVC.tailgateName = self.tailgateName
        suppliesVC.tailgateSchool = self.tailgateSchool
        suppliesVC.isPublic = self.isPublic
        suppliesVC.startTime = self.startDatePicker.date
    }
}
