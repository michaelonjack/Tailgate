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
    var selectedDrinks:[Drink] = []
    var searchText:String = "" {
        didSet {
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
        self.selectedDrinks.append( drinks[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}



extension CreateTailgateDrinkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkTableCell", for: indexPath) as! DrinkTableViewCell
        
        // Reset the recycled cell's label
        cell.drinkNameLabel.text = ""
        
        var matchesFound = 0
        for index in 0...self.drinks.count-1 {
            let currDrink = self.drinks[index]
            
            if self.searchText == "" || currDrink.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                // We want to skip over matches that were already added to the table
                if matchesFound == indexPath.row {
                    cell.drinkNameLabel.text = currDrink.name
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
            
            for drink in drinks {
                if drink.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                    count = count + 1
                }
            }
            
            return count
        }
            
        else {
            return self.drinks.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
