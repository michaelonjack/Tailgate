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
    var searchResults:[Food] = []
    var selectedFoods:[Food] = []
    var searchText:String = "" {
        didSet {
            if searchText == "" {
                searchResults = foods
            } else {
                searchResults = []
                for food in foods {
                    if food.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                        searchResults.append(food)
                    }
                }
            }
            
            foodTable.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        foodTable.delegate = self
        foodTable.dataSource = self
        foodTable.allowsMultipleSelection = true
        foodTable.backgroundView = EmptyBackgroundView(scrollView: self.foodTable, image: UIImage(named: "Food2")!, title: "No Food :(", message: "Tailgate with no food...hard pass..")
        
        searchTextField.delegate = self
        
        getFood(completion: { (foods) in
            self.foods = foods
            self.searchResults = foods
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
        self.selectedFoods.append( searchResults[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Remove the friend from the friends list when deselected
        let unselectedFoodId = searchResults[indexPath.row].id
        
        self.selectedFoods = self.selectedFoods.filter{$0.id != unselectedFoodId}
    }
    
}



extension CreateTailgateFoodViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTableCell", for: indexPath) as! FoodTableViewCell
        
        let currFood = self.searchResults[indexPath.row]
        
        // Reset the recycled cell's label
        cell.foodNameLabel.text = ""
        
        cell.foodNameLabel.text = currFood.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchResults.count > 0 {
            foodTable.backgroundView?.isHidden = true
            foodTable.separatorStyle = .singleLine
        } else {
            foodTable.backgroundView?.isHidden = false
            foodTable.separatorStyle = .none
        }
        
        return self.searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
