//
//  SettingsViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 2/24/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsTable: UITableView!
    
    let sectionTitles = ["ACCOUNT", "ACCOUNT ACTIONS", "INFORMATION"]
    var rowData = [
        [("First Name", ""), ("Last Name", ""), ("Email", ""), ("Birthday", "")],
        [("Logout", ""), ("Change Password", "")],
        [("Contact", "")]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingsTable.delegate = self
        self.settingsTable.dataSource = self
        self.settingsTable.rowHeight = UITableViewAutomaticDimension
        self.settingsTable.estimatedRowHeight = 44.0
        
        initNavBar()
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func exitPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadData() {
        let currentUserReference = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
        
        currentUserReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let userData = snapshot.value as? NSDictionary
            
            self.rowData[0][0].1 = userData?["firstName"] as? String ?? ""
            self.rowData[0][1].1 = userData?["lastName"] as? String ?? ""
            self.rowData[0][2].1 = userData?["email"] as? String ?? ""
            self.rowData[0][3].1 = userData?["birthday"] as? String ?? ""
            
            DispatchQueue.main.async {
                self.settingsTable.reloadData()
            }
        })
    }

    func initNavBar() {
        // Change font and color of nav header
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22.0), NSAttributedStringKey.foregroundColor: UIColor.white]
        
        // Add the exit button
        let exitButton = UIButton(type: UIButtonType.custom)
        exitButton.setBackgroundImage(UIImage(named: "ExitNav"), for: .normal)
        exitButton.addTarget(self, action: #selector(exitPressed(_:)), for: .touchUpInside)
        exitButton.widthAnchor.constraint(equalToConstant: 27.0).isActive = true
        exitButton.heightAnchor.constraint(equalToConstant: 27.0).isActive = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: exitButton)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "SettingsToBirthday":
            let birthdayController: SettingsBirthdayViewController = segue.destination as! SettingsBirthdayViewController
            
            let birthdayString = self.rowData[0][3].1
            birthdayController.initialDateString = birthdayString
            birthdayController.presentingController = self
            
        case "SettingsToName":
            let nameController: SettingsNameViewController = segue.destination as! SettingsNameViewController
            
            nameController.firstName = self.rowData[0][0].1
            nameController.lastName = self.rowData[0][1].1
            nameController.presentingController = self
            
        case "SettingsToEmail":
            let emailController: SettingsEmailViewController = segue.destination as! SettingsEmailViewController
            
            emailController.email = self.rowData[0][2].1
            emailController.presentingController = self
            
        default:
            var _ = 0
        }
    }
}



extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRowName = self.rowData[indexPath.section][indexPath.row].0
        
        switch selectedRowName {
        case "Logout":
            do {
                try Auth.auth().signOut()
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {break}
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = mainStoryboard.instantiateViewController(withIdentifier: "InitialNavigationController") as! UINavigationController
                appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
                appDelegate.window?.rootViewController = initialViewController
            } catch {
                print("Sign out failure")
            }
        
        case "Change Password":
            self.performSegue(withIdentifier: "SettingsToChangePassword", sender: nil)
        
        case "Birthday":
            self.performSegue(withIdentifier: "SettingsToBirthday", sender: nil)
            
        case "First Name", "Last Name":
            self.performSegue(withIdentifier: "SettingsToName", sender: nil)
        
        case "Email":
            self.performSegue(withIdentifier: "SettingsToEmail", sender: nil)
        
        default:
            var _ = 0
        }
    }
}



extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .white
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 13)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
            headerView.backgroundView = backgroundView
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sectionTitles[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowData[section].count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableCell", for: indexPath) as! SettingsTableViewCell
        
        let rowName = self.rowData[indexPath.section][indexPath.row].0
        let rowValue = self.rowData[indexPath.section][indexPath.row].1
        
        cell.rowNameLabel.text = rowName
        cell.rowValueLabel.text = rowValue
        
        return cell
    }
}
