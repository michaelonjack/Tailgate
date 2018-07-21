//
//  TrashTalkReportViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 7/17/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import FirebaseDatabase
import NotificationBannerSwift

class TrashTalkReportViewController: UIViewController {

    @IBOutlet weak var reportTextView: UITextView!
    
    var game:Game!
    var messageId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Give the text view a border
        reportTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        reportTextView.layer.borderWidth = 1.5
        reportTextView.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func submitReportPressed(_ sender: Any) {
        // Create the new report
        if self.reportTextView.text != "" {
            let report = Report(report: self.reportTextView.text, reportingUserId: getCurrentUserId(), game: game, messageId: messageId)
            
            let reportsReference = Database.database().reference(withPath: "reports/" + report.id)
            reportsReference.setValue(report.toAnyObject())
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                
                let confirmationBanner = NotificationBanner(attributedTitle: NSAttributedString(string: "Report Submitted"), attributedSubtitle: NSAttributedString(string: "Your report will be reviewed and any offending content will be removed if rules have been violated."), style: .success)
                
                confirmationBanner.show()
            }
        }
            
        else {
            let alert = createAlert(title: "A reason for the report is required.", message: "")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
