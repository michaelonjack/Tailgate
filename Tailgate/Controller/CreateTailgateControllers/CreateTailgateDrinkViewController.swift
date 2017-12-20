//
//  CreateTailgateDrinkViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/16/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class CreateTailgateDrinkViewController: UIViewController {

    @IBOutlet weak var drinksTable: UITableView!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    var startTime: Date!
    var foods:[String]!
    
    var drinks:[String] = ["Vlad", "Jonboy", "Vlad Ham"]
    var selectedDrinks:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drinksTable.delegate = self
        drinksTable.dataSource = self
        drinksTable.allowsMultipleSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "DrinkToInvites", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let invitesVC: CreateTailgateInvitesViewController = segue.destination as! CreateTailgateInvitesViewController
        invitesVC.tailgateName = self.tailgateName
        invitesVC.tailgateSchool = self.tailgateSchool
        invitesVC.isPublic = self.isPublic
        invitesVC.startTime = self.startTime
        invitesVC.foods = self.foods
        invitesVC.drinks = self.selectedDrinks
    }
}



extension CreateTailgateDrinkViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedDrinks.append( drinks[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}



extension CreateTailgateDrinkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkTableCell", for: indexPath) as! DrinkTableViewCell
        
        cell.drinkNameLabel.text = drinks[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.foods.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
