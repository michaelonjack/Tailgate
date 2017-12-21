//
//  CreateTailgateInvitesViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/19/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class CreateTailgateInvitesViewController: UIViewController {
    
    @IBOutlet weak var usersTable: UITableView!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    var startTime: Date!
    var foods:[String]!
    var drinks:[String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
