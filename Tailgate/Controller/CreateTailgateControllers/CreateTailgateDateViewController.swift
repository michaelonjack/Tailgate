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
        self.performSegue(withIdentifier: "DateToFood", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let foodVC: CreateTailgateFoodViewController = segue.destination as! CreateTailgateFoodViewController
        foodVC.tailgateName = self.tailgateName
        foodVC.tailgateSchool = self.tailgateSchool
        foodVC.isPublic = self.isPublic
        foodVC.startTime = self.startDatePicker.date
    }
}
