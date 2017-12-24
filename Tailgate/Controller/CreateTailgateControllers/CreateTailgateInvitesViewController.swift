//
//  CreateTailgateInvitesViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/19/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase

class CreateTailgateInvitesViewController: UIViewController {
    
    @IBOutlet weak var usersTable: UITableView!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    var startTime: Date!
    var foods:[Food]!
    var drinks:[Drink]!
    
    var invites:[User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createPressed(_ sender: Any) {
        
        let newTailgate = Tailgate(owner: (Auth.auth().currentUser?.uid)!, name: tailgateName, school: tailgateSchool, isPublic: isPublic, startTime: startTime, foods: foods, drinks: drinks, invites: invites)
        
        let tailgateReference = Database.database().reference(withPath: "tailgates/" + newTailgate.id)
        tailgateReference.setValue(newTailgate.toAnyObject())
        
        let userTailgateReference = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)! + "/tailgate")
        userTailgateReference.setValue(newTailgate.id)
        
        // Create a new controller to hold the new tailgate data
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tailgateViewController = mainStoryboard.instantiateViewController(withIdentifier: "TailgateViewController") as! TailgateViewController
        tailgateViewController.tailgate = newTailgate
        
        self.containerSwipeNavigationController?.showEmbeddedView(position: .center)
        self.containerSwipeNavigationController?.rightViewController = tailgateViewController
    }
    
}
