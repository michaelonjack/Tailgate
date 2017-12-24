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
    @IBOutlet weak var searchTextField: UITextField!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    var startTime: Date!
    
    var foods:[Food] = []
    var selectedFoods:[Food] = []
    var searchText:String = "" {
        didSet {
            foodTable.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        foodTable.delegate = self
        foodTable.dataSource = self
        foodTable.allowsMultipleSelection = true
        
        searchTextField.delegate = self
        
        getFood(completion: { (foods) in
            self.foods = foods
            self.foodTable.reloadData()
        })
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



extension CreateTailgateFoodViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedValue = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        self.searchText = updatedValue
        return true
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
        
        // Reset the recycled cell's label
        cell.foodNameLabel.text = ""
        
        var matchesFound = 0
        for index in 0...self.foods.count-1 {
            let currFood = self.foods[index]
            
            if self.searchText == "" || currFood.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                // We want to skip over matches that were already added to the table
                if matchesFound == indexPath.row {
                    cell.foodNameLabel.text = currFood.name
                    break
                }
                matchesFound = matchesFound + 1
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchText != "" {
            var count = 0
            
            for food in foods {
                if food.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                    count = count + 1
                }
            }
            
            return count
        }
            
        else {
            return self.foods.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
