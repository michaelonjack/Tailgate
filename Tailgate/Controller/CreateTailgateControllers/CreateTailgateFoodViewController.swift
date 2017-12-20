//
//  CreateTailgateFoodViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/16/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class CreateTailgateFoodViewController: UIViewController {
    
    @IBOutlet weak var foodTable: UITableView!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    var startTime: Date!
    
    var foods:[String] = ["Chips", "Salsa", "Rum Ham"]
    var selectedFoods:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        foodTable.delegate = self
        foodTable.dataSource = self
        foodTable.allowsMultipleSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "FoodToDrink", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let drinkVC: CreateTailgateDrinkViewController = segue.destination as! CreateTailgateDrinkViewController
        drinkVC.tailgateName = self.tailgateName
        drinkVC.tailgateSchool = self.tailgateSchool
        drinkVC.isPublic = self.isPublic
        drinkVC.startTime = self.startTime
        drinkVC.foods = self.selectedFoods
    }
}



extension CreateTailgateFoodViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedFoods.append( foods[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}



extension CreateTailgateFoodViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTableCell", for: indexPath) as! FoodTableViewCell
        
        cell.foodNameLabel.text = foods[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.foods.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
