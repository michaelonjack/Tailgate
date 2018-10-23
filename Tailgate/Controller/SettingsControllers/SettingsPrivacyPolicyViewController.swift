//
//  PrivacyPolicyViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 10/22/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class SettingsPrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var policyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change font and color of nav header
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0), NSAttributedString.Key.foregroundColor: UIColor.white]
        
        
        // Add additional styling to the Terms of Service
        let attributedText = NSMutableAttributedString(attributedString: self.policyLabel.attributedText!)
        
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold)], range: getRangeOfSubString(subString: "Privacy Policy", fromString: self.policyLabel.text!))
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], range: getRangeOfSubString(subString: "Information We Collect", fromString: self.policyLabel.text!))
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], range: getRangeOfSubString(subString: "How We Use the Information", fromString: self.policyLabel.text!))
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], range: getRangeOfSubString(subString: "Control Over Your Information", fromString: self.policyLabel.text!))
        
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], range: getRangeOfSubString(subString: "Revisions to the Privacy Policy", fromString: self.policyLabel.text!))
        
        self.policyLabel.attributedText = attributedText
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func closePressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func getRangeOfSubString(subString: String, fromString: String) -> NSRange {
        let sampleLinkRange = fromString.range(of: subString)!
        let startPos = fromString.distance(from: fromString.startIndex, to: sampleLinkRange.lowerBound)
        let endPos = fromString.distance(from: fromString.startIndex, to: sampleLinkRange.upperBound)
        let linkRange = NSMakeRange(startPos, endPos - startPos)
        
        return linkRange
    }

}
