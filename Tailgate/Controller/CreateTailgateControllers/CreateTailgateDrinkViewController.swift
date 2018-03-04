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
    @IBOutlet weak var searchTextField: UITextField!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    var startTime: Date!
    var foods:[Food]!
    
    var drinks:[Drink] = []
    var searchResults:[Drink] = []
    var selectedDrinks:[Drink] = []
    var searchText:String = "" {
        didSet {
            if searchText == "" {
                searchResults = drinks
            } else {
                searchResults = []
                for drink in drinks {
                    if drink.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                        searchResults.append(drink)
                    }
                }
            }
            
            drinksTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drinksTable.delegate = self
        drinksTable.dataSource = self
        drinksTable.allowsMultipleSelection = true
        
        searchTextField.delegate = self
        
        getDrinks(completion: { (drinks) in
            self.drinks = drinks
            self.searchResults = drinks
            self.drinksTable.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "DrinkToFlair", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let flairVC: CreateTailgateFlairViewController = segue.destination as! CreateTailgateFlairViewController
        flairVC.tailgateName = self.tailgateName
        flairVC.tailgateSchool = self.tailgateSchool
        flairVC.isPublic = self.isPublic
        flairVC.startTime = self.startTime
        flairVC.foods = self.foods
        flairVC.drinks = self.selectedDrinks
    }
}



extension CreateTailgateDrinkViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedValue = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        self.searchText = updatedValue
        return true
    }
    
}



extension CreateTailgateDrinkViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedDrinks.append( searchResults[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Remove the friend from the friends list when deselected
        let unselectedDrinkId = searchResults[indexPath.row].id
        
        self.selectedDrinks = self.selectedDrinks.filter{$0.id != unselectedDrinkId}
    }
    
}



extension CreateTailgateDrinkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkTableCell", for: indexPath) as! DrinkTableViewCell
        
        let currDrink = self.searchResults[indexPath.row]
        
        // Reset the recycled cell's label
        cell.drinkNameLabel.text = ""
        
        cell.drinkNameLabel.text = currDrink.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
