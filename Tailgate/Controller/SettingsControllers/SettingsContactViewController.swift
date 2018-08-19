//
//  SettingsContactViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 8/19/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class SettingsContactViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change font and color of nav header
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22.0), NSAttributedStringKey.foregroundColor: UIColor.white]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
