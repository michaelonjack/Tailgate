//
//  Report.swift
//  Tailgate
//
//  Created by Michael Onjack on 6/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation

class Report {
    
    let id:String!
    let report:String!
    let reportingUserId:String!
    let reportedUserId:String!
    let tailgateId:String!
    var threadName:String!
    let submissionDate:Date!
    var submissionDateStr:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: self.submissionDate)
    }
    
    init(report:String, reportingUserId:String, reportedUserId:String, tailgateId:String) {
        self.id = UUID().uuidString
        self.report = report
        self.reportingUserId = reportingUserId
        self.reportedUserId = reportedUserId
        self.tailgateId = tailgateId
        self.threadName = ""
        self.submissionDate = Date()
    }
    
    init(report:String, reportingUserId:String, game:Game) {
        self.id = UUID().uuidString
        self.report = report
        self.reportingUserId = reportingUserId
        self.reportedUserId = ""
        self.tailgateId = ""
        self.threadName = game.awayTeam.replacingOccurrences(of: " ", with: "") + "at" + game.homeTeam.replacingOccurrences(of: " ", with: "")
        self.submissionDate = Date()
    }
    
    func toAnyObject() -> Any {
        return [
            "report": report,
            "reportingUserId": reportingUserId,
            "reportedUserId": reportedUserId,
            "tailgateId": tailgateId,
            "submissionDate": submissionDateStr,
            "threadName": threadName
        ]
    }
    
}
