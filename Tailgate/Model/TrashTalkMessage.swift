//
//  TrashTalkMessage.swift
//  Tailgate
//
//  Created by Michael Onjack on 7/9/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import MessageKit
import FirebaseDatabase
import SDWebImage

enum MediaStatus {
    case notLoaded
    case loading
    case loaded
    case error
}

struct TrashTalkMessage: MessageType {
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var sentDateStr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self.sentDate)
    }
    var data: MessageData
    var senderTeam: School?
    var imgUrl: URL?
    var score: Int
    var mediaStatus: MediaStatus
    var showDetail:Bool
    
    private init(data: MessageData, sender: Sender, messageId: String, date: Date, team: School?) {
        self.data = data
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.senderTeam = team
        self.score = 0
        self.mediaStatus = .notLoaded
        self.showDetail = false
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date, team: School?) {
        self.init(data: .text(text), sender: sender, messageId: messageId, date: date, team: team)
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date, team: School?) {
        self.init(data: .attributedText(attributedText), sender: sender, messageId: messageId, date: date, team: team)
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date, team: School?) {
        self.init(data: .photo(image), sender: sender, messageId: messageId, date: date, team: team)
    }
    
    init(emoji: String, sender: Sender, messageId: String, date: Date, team: School?) {
        self.init(data: .emoji(emoji), sender: sender, messageId: messageId, date: date, team: team)
    }
    
    init(snapshot:DataSnapshot) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.messageId = snapshot.key
        self.sentDate = formatter.date(from: snapshotValue["sentDate"] as? String ?? "")!
        self.score = snapshotValue["score"] as? Int ?? 0
        self.senderTeam = configuration.schoolCache[snapshotValue["senderTeam"] as? String ?? ""]
        self.mediaStatus = .notLoaded
        self.showDetail = false
        
        // Set the sender
        let senderId = snapshotValue["sender"]!["id"] as? String ?? ""
        let senderDisplayName = snapshotValue["sender"]!["displayName"] as? String ?? ""
        self.sender = Sender(id: senderId, displayName: senderDisplayName)
        
        // Set the message data
        if let messageData = snapshotValue["data"], let messageType = messageData["type"] as? String {
            switch messageType {
            case "text":
                let messageText = messageData["value"] as? String ?? ""
                self.data = .text(messageText)
            case "photo":
                if let imageUrlStr = messageData["url"] as? String {
                    let imageUrl = URL(string: imageUrlStr)
                    self.imgUrl = imageUrl
                    self.data = .photo(UIImage(named: "Loading")!)
                }
                
                else {
                    self.data = .text("error")
                }
                
            default:
                self.data = .text("error")
            }
        } else {
            self.data = .text("error")
        }
    }
    
    func toAnyObject() -> Any {
        
        var messageData:[String:Any] = [:]
        switch data {
        case .text(let str):
            messageData["type"] = "text"
            messageData["value"] = str
        case .photo(_):
            messageData["type"] = "photo"
            if let url = self.imgUrl {
                messageData["url"] = url.absoluteString
            }
        default:
            break
        }
        
        return [
            "sentDate": sentDateStr,
            "score": score,
            "sender": ["id":sender.id, "displayName":sender.displayName, "userId": configuration.currentUser.uid],
            "senderTeam": senderTeam?.name ?? "",
            "data": messageData
        ]
    }
}
