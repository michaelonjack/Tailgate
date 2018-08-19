//
//  TutorialViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 8/19/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topConstraint.updateVerticalConstantForViewHeight(view: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
